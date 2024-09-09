Class {
	#name : #ExerciseMenu,
	#superclass : #Morph,
	#instVars : [
		'window',
		'selectedItem',
		'exerciseList',
		'normalList',
		'removeExerciseButton',
		'addExerciseButton',
		'addBackButton',
		'openSelectedButton'
	],
	#category : #MyPackage
}

{ #category : #actions }
ExerciseMenu >> addNewExercise [
	| newExerciseName |
	
	newExerciseName := UIManager default request: 'Enter new exercise name:'.
    
	"return if cancel pressed"
	newExerciseName ifNil: [ ^ [  ]. ].

	"if the field is empty dont add"
	newExerciseName ifNotEmpty: [ 
		"add new exercise"
		normalList add: newExerciseName.
		
		"write list to file"
		self writeListToFile: normalList.
		
		"update the morph with new element"
		exerciseList update: #loadExercisesFromFile.
	].
]

{ #category : #initialization }
ExerciseMenu >> initialize [ 
	super initialize.
   
	window := SystemWindow new.
	window setLabel: 'Exercise Menu'.
	
	exerciseList := PluggableListMorph
		on: self
		list: #loadExercisesFromFile 
		selected: #selectedItem
		changeSelected: #updateSelection:.
	
	addExerciseButton := SimpleButtonMorph new
		label: 'Add New Exercise';
		target: self;
		actionSelector: #addNewExercise;
		openInWorld.
	removeExerciseButton := SimpleButtonMorph new
		label: 'Delete selected';
		target: self;
		actionSelector: #removeExercise;
		openInWorld.
	
	addBackButton := SimpleButtonMorph new
		label: 'Back';
		target: self;
		actionSelector: #openMainMenu;
		openInWorld.
	
	openSelectedButton  := SimpleButtonMorph new
		label: 'Open Selected';
		target: self;
		actionSelector: #openSelected;
		openInWorld.
		
	window addMorph: exerciseList frame: (0.1@0.1 corner: 0.6@0.7).	
	window addMorph: openSelectedButton frame: (0.65@0.3 corner: 0.85@0.4).
	window addMorph: removeExerciseButton frame: (0.65@0.45 corner: 0.85@0.55).
	window addMorph: addExerciseButton frame: (0.1@0.72 corner: 0.6@0.82).
	window addMorph: addBackButton frame: (0.1@0.83 corner: 0.6@0.93).

	window openInWorld.
]

{ #category : #actions }
ExerciseMenu >> loadExercisesFromFile [
	| fileReference contents |

	"file path"
	fileReference := 'exercises.txt' asFileReference.
	
	"creates an empty collection"
	normalList := OrderedCollection new. 

	"if a file doesn't exist create a new empty one"
	fileReference exists ifFalse: [ fileReference writeStreamDo: [ :stream | ] ].
	
	"read the contents"
	fileReference readStreamDo: [ :stream | contents := stream contents. ].

	"split into lines"
	contents linesDo: [ :line | normalList add: line ].

	"return list of lines"
	^ normalList
]

{ #category : #actions }
ExerciseMenu >> openMainMenu [ 
	| mainMenuwindow |
	
	mainMenuwindow := MainMenu new.
	mainMenuwindow openInWorld.
	
	window delete.
	self delete.
]

{ #category : #actions }
ExerciseMenu >> openSelected [
	| sessionMenu exeName |

	"returns if nothing is selected"
	selectedItem ifNil: [
		UIManager default inform: 'Please select an item first.'.
		^ [ ].
		].
	"get name of selectedItem"
	exeName := (normalList at: selectedItem).
	
	"open session menu with the selected exercise"
	sessionMenu := SessionMenu newSessionWithName: exeName.
	sessionMenu openInWorld.
	
	window delete.
	self delete.
]

{ #category : #actions }
ExerciseMenu >> removeExercise [
	
	"check if sI is in bounds or nil"
	(selectedItem isNil
		or: [ (selectedItem <= 0 or: [ selectedItem > normalList size ]) ])
		ifTrue: [ ^ [  ] ].

	"remove item from list"
	normalList removeAt: selectedItem.

	"write new list to file"
	self writeListToFile: normalList.

	"update visual"
	exerciseList update: #loadExercisesFromFile
]

{ #category : #'pluggable menus' }
ExerciseMenu >> selectedItem [
		^ selectedItem.
]

{ #category : #'pluggable menus' }
ExerciseMenu >> selectedItem: anItem [
		
		selectedItem := anItem.
		self updateUI.
]

{ #category : #'pluggable menus' }
ExerciseMenu >> updateSelection: anItem [

		self selectedItem: anItem.
		self updateUI.
]

{ #category : #'pluggable menus' }
ExerciseMenu >> updateUI [

	exerciseList update: #loadExercisesFromFile.
]

{ #category : #actions }
ExerciseMenu >> writeListToFile: aList [
	| fileReference |
	
	"file path"
	fileReference := 'exercises.txt' asFileReference.
	
	"clear file"
	fileReference binaryWriteStreamDo: [ :stream |
		stream truncate.
	].
	"write new list into file"
	fileReference writeStreamDo: [ :stream |
		aList do: [ :each |
			stream nextPutAll: each; cr. 
		].
	].
]
