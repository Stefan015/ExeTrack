Class {
	#name : #MainMenu,
	#superclass : #Morph,
	#instVars : [
		'window',
		'exercisesButton',
		'exitButton'
	],
	#category : #MyPackage
}

{ #category : #actions }
MainMenu >> exitApplication [ 
	window delete.
]

{ #category : #initialization }
MainMenu >> initialize [ 
	super initialize.
	
	window := SystemWindow new.
	window setLabel: 'Main Menu'.
	
	exercisesButton := SimpleButtonMorph new
		label: 'Exercises';
		target: self;
		actionSelector: #openExerciseMenu;
		openInWorld.

	exitButton := SimpleButtonMorph new
		label: 'Exit';
		target: self;
		actionSelector: #exitApplication;
		openInWorld.

	window addMorph: exercisesButton frame: (0.25@0.3 corner: 0.75@0.5). 
	window addMorph: exitButton frame: (0.3@0.65 corner: 0.7@0.75).

	window openInWorld.
]

{ #category : #actions }
MainMenu >> openExerciseMenu [
	| exerciseMenu |
	
	exerciseMenu := ExerciseMenu new.
	exerciseMenu openInWorld.
	
	window delete.
	self delete.
]
