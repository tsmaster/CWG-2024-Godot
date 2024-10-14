extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Use a custom random number generator
	var rng = RandomNumberGenerator.new()
	
	# A simple grammar - or read from a JSON file
	var grammar_test = Dictionary()
	grammar_test["sentence"] = ["A #color# #animal.capitalize#"]
	grammar_test["animal"] = ["dog", "cat", "mouse", "rat", "cow", "pig", "unicorn"]
	grammar_test["color"] = ["#tone# #baseColor#"]
	grammar_test["tone"] = ["dark", "light", "pale"]
	grammar_test["baseColor"] = ["red", "green", "blue", "yellow"]
	
	# Create our grammar
	var grammar = Tracery.Grammar.new( grammar_test )

	# Use our custom random number generator
	grammar.set_rng(rng)
	
	# Add the english modifiers
	grammar.add_modifiers(Tracery.UniversalModifiers.get_modifiers())
	
	# Flatten / generate a couple of sentences
	for i in range( 0, 5 ):
		var sentence = grammar.flatten("#sentence#")
		print(sentence)
		
