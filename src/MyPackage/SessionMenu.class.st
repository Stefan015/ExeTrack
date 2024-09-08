Class {
	#name : #SessionMenu,
	#superclass : #Morph,
	#instVars : [
		'window',
		'exerciseName',
		'selectedItem',
		'normalList',
		'sessionList',
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
	
	sessionNumber := normalList size + 1.
	
	weight := UIManager default request: 'Enter the weight used in the session'.
	repetitions := UIManager default request: 'Enter the number of repetitons performed'.
	sets := UIManager default request: 'Enter the number of sets done'.
	
	session := 'Session #', sessionNumber printString,' Weight used: ', weight,' Sets: ', sets,' Repetitions: ', repetitions.
	
	"Debug message to Transcript"
	Transcript show: 'Session string: ';show: session; cr.

	normalList add: session.
	self writeListToFile: normalList.
	sessionList update: #loadSessionData.

]

{ #category : #actions }
SessionMenu >> ensureDirectoryExists: directoryPath [
	| directoryReference |
	
	directoryReference := directoryPath asFileReference.
	directoryReference isDirectory
		ifTrue: [ ^ self ].
		
	directoryReference createDirectory
]

{ #category : #'set and get' }
SessionMenu >> getExeName [ 
	^ exerciseName.
]

{ #category : #initialization }
SessionMenu >> initialize [
	"needed for construtor"
	super initialize.
]

{ #category : #actions }
SessionMenu >> loadSessionData [
		| directoryPath fileReference filePath contents |
	
	normalList := OrderedCollection new.
	
	directoryPath := '/exercises'.
	
	self ensureDirectoryExists: directoryPath.
	
	"file path"
	filePath := directoryPath ,'/', self getExeName, '.txt'.
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
	
	window delete
]

{ #category : #'pluggable menus' }
SessionMenu >> selectedItem [
		^ selectedItem.
]

{ #category : #'pluggable menus' }
SessionMenu >> selectedItem: anItem [

		selectedItem := anItem.
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


	window addMorph: sessionList frame: (0.1@0.1 corner: 0.9@0.6).
	window addMorph: addBackButton frame: (0.1@0.74 corner: 0.9@0.84).
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

{ #category : #actions }
SessionMenu >> writeListToFile: aList [
	| fileReference directoryPath filePath |
	
	directoryPath := '/exercises'.
	filePath := directoryPath ,'/', self getExeName, '.txt'.
	fileReference := filePath asFileReference.
	
	"write list to file"
	fileReference writeStreamDo: [ :stream |
		aList do: [ :each |
			stream nextPutAll: each; cr. 
		]. 
	].
]
