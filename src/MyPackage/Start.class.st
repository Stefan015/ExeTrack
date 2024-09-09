Class {
	#name : #Start,
	#superclass : #Object,
	#category : #MyPackage
}

{ #category : #start }
Start >> run [ 
	| menu |
	
	menu := MainMenu new.
	menu openInWorld.
]
