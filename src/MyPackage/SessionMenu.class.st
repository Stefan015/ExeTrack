Class {
	#name : #SessionMenu,
	#superclass : #Morph,
	#instVars : [
		'window',
		'exerciseName',
		'selectedItem',
		'normalList',
		'sessionList',
		'removeSessionButton',
		'addSessionButton',
		'addBackButton'
	],
	#category : #MyPackage
}

{ #category : #initialization }
SessionMenu class >> newSessionWithName: anExerciseName [
	| instance |
	"creates an instance where exerciseName is initialized before loadSessionData is called which needs exerciseName"
	
	instance := self new.
	instance setExeName: anExerciseName.
	
	instance setupWindow.
	instance setupUIComponents.


	^ instance.
]

{ #category : #actions }
SessionMenu >> addNewSession [ 
	| weight repetitions sets session sessionNumber |
	
	"keep track of session number"
	sessionNumber := normalList size + 1.
	
	"user input"
	weight := UIManager default request: 'Enter the weight used in the session'.
	weight ifNil: [ ^ [ ] ].
	weight ifEmpty: [ UIManager default inform: 'Field left empty.'. ^ [ ] ].
		
	repetitions := UIManager default request: 'Enter the number of repetitons performed'.
	repetitions ifNil: [ ^ [ ] ].
	repetitions ifEmpty: [ UIManager default inform: 'Field left empty.'. ^ [ ] ].
	
	sets := UIManager default request: 'Enter the number of sets done'.
	sets ifNil: [ ^ [ ] ].
	sets ifEmpty: [ UIManager default inform: 'Field left empty.'. ^ [ ] ].

	"create a string to be added to collection "
	session := 'Session #', sessionNumber printString,' Weight used: ', weight,' Sets: ', sets,' Repetitions: ', repetitions.
	
	"add the new session "
	normalList add: session.
	
	"write new list to file "
	self writeListToFile: normalList.
	
	"update visual"	
	sessionList update: #loadSessionData.

]

{ #category : #actions }
SessionMenu >> ensureDirectoryExists: directoryPath [
	| directoryReference |
	
	"check if directory exists if not create a new one"
	directoryReference := directoryPath asFileReference.
	directoryReference isDirectory
		ifTrue: [ ^ self ].
		
	directoryReference createDirectory
]

{ #category : #'set and get' }
SessionMenu >> getDirectoryPath [
	| directoryPath |
	
	directoryPath :=  (FileSystem workingDirectory) / 'exercises'.
	^ directoryPath.
]

{ #category : #'set and get' }
SessionMenu >> getExeName [ 
	^ exerciseName.
]

{ #category : #'set and get' }
SessionMenu >> getFilePath [
	| filePath |
	
	filePath := self getDirectoryPath / (self getExeName, '.txt').
	
	^ filePath.
]

{ #category : #initialization }
SessionMenu >> initialize [
	"needed for construtor"
	super initialize.
]

{ #category : #actions }
SessionMenu >> loadSessionData [
		| directoryPath fileReference filePath contents |
	
	"initialize list "
	normalList := OrderedCollection new.
	
	"get path"
	directoryPath := self getDirectoryPath.
	
	"create dir if needed"
	self ensureDirectoryExists: directoryPath .
	
	"file path"
	filePath := self getFilePath.
	fileReference := filePath asFileReference.
	
	"if a file doesn't exist create a new empty one"
	fileReference exists ifFalse: [ fileReference writeStreamDo: [ :stream | ] ].
	
	"read the contents"
	fileReference readStreamDo: [ :stream | contents := stream contents. ].

	"split into lines"
	contents linesDo: [ :line | normalList add: line ].

	"return list of lines"
	^ normalList
]

{ #category : #initialization }
SessionMenu >> new [
	"needed for construtor"
	super new.
]

{ #category : #actions }
SessionMenu >> openExerciseMenu [
	| mainMenuwindow |
	
	mainMenuwindow := ExerciseMenu new.
	mainMenuwindow openInWorld.
	
	window delete.
	self delete.
]

{ #category : #actions }
SessionMenu >> removeSession [
	
	"check if SI is within bounds or nil"
	(selectedItem isNil
		or: [ (selectedItem <= 0 or: [ selectedItem > normalList size ]) ])
		ifTrue: [ ^ [  ] ].
	
	"remove the element from list"
	normalList removeAt: selectedItem.
	
	"write the new list without item"
	self writeListToFile: normalList.
	
	"update visual"
	sessionList update: #loadSessionData.
]

{ #category : #'pluggable menus' }
SessionMenu >> selectedItem [
		^ selectedItem.
]

{ #category : #'pluggable menus' }
SessionMenu >> selectedItem: anItem [

		selectedItem := anItem.
		self updateUI.
]

{ #category : #'set and get' }
SessionMenu >> setExeName: aName [

	exerciseName := aName.
]

{ #category : #initialization }
SessionMenu >> setupUIComponents [

	sessionList := PluggableListMorph
		on: self
		list: #loadSessionData
		selected: #selectedItem
		changeSelected: #updateSelection:.

	addSessionButton := SimpleButtonMorph new
		label: 'Add a new session';
		target: self;
		actionSelector: #addNewSession.
		
	addBackButton := SimpleButtonMorph new
		label: 'Back';
		target: self;
		actionSelector: #openExerciseMenu;
		openInWorld.
	
	removeSessionButton := SimpleButtonMorph new
		label: 'Delete selected';
		target: self;
		actionSelector: #removeSession;
	openInWorld.


	window addMorph: sessionList frame: (0.1@0.1 corner: 0.9@0.6).
	window addMorph: addBackButton frame: (0.1@0.86 corner: 0.9@0.96).
	window addMorph: removeSessionButton frame: (0.1@0.74 corner: 0.9@0.84).
	window addMorph: addSessionButton frame: (0.1@0.62 corner: 0.9@0.72).

	window openInWorld.
]

{ #category : #initialization }
SessionMenu >> setupWindow [

    window := SystemWindow new.
    window setLabel: 'Session Menu'.
]

{ #category : #'pluggable menus' }
SessionMenu >> updateSelection: anItem [

		self selectedItem: anItem.
]

{ #category : #'pluggable menus' }
SessionMenu >> updateUI [
	sessionList  update: #loadSessionData.
]

{ #category : #actions }
SessionMenu >> writeListToFile: aList [
	| fileReference filePath |
	
	"get file path"
	filePath := self getFilePath.
	fileReference := filePath asFileReference.
	
	"clear file before writing"
	fileReference binaryWriteStreamDo: [ :stream |
		stream truncate.
	].

	"write list to file"
	fileReference writeStreamDo: [ :stream |
		aList do: [ :each |
			stream nextPutAll: each; cr. 
		]. 
	].
]
