Class {
	#name : #ExerciseMenu,
	#superclass : #Morph,
	#instVars : [
		'window',
		'selectedItem',
		'exerciseList',
		'normalList',
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
	window addMorph: openSelectedButton frame: (0.65@0.35 corner: 0.85@0.5).
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
	
	window delete
]

{ #category : #actions }
ExerciseMenu >> openSelected [ 
	"takes the value from the pluggable list and calls session menu passing that value"
	| sessionMenu exeName |

	"returns if nothing is selected"
	selectedItem ifNil: [
		UIManager default inform: 'Please select an item first.'.
		^ [ ].
		].
	
	exeName := (normalList at: selectedItem).
	
	"open session menu with the selected exercise"
	sessionMenu := SessionMenu newSessionWithName: exeName.
	
	sessionMenu openInWorld.
	
	window delete.
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
]

{ #category : #'pluggable menus' }
ExerciseMenu >> updateUI [
    self update: exerciseList.
]

{ #category : #actions }
ExerciseMenu >> writeListToFile: aList [
	| fileReference |
	
	"file path"
	fileReference := 'exercises.txt' asFileReference.
	
	"write list to file"
	fileReference writeStreamDo: [ :stream |
		aList do: [ :each |
			stream nextPutAll: each; cr. 
		].
	].
]
