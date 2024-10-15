extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Use a custom random number generator
	var rng = RandomNumberGenerator.new()
	
	# A simple grammar - or read from a JSON file
	var grammar_test = Dictionary()
	grammar_test["sentence"] = ["A #color# #animal.capitalize#"]
	grammar_test["animal"] = [  
		"aardvark", "butterfly", "ape",
		"caribou", "cat", "cow", "chimpanzee", 
		"dog", "dormouse",
		"echidna", "elk", 
		"frog", 
		"grouper", "giraffe", "gull", 
		"hawk", "hen",
		"iguana", 
		"jackal", "jaguar", "jellyfish", "jay", 
		"kestrel", "koala",
		"llama", "lion", "leopard", "lemur", 
		"mouse", "marmoset", "marmot", "mandrill", "monkey",
		"newt", "narwhal", 
		"ostritch", "orangutan", "ox",
		"panda", "pangolin", "penguin", "pig",
		"quail", 
		"rabbit", "rat", "rooster", 
		"snake", "snail", 
		"tiger", "turtle", "terrapin", "tortoise", "tardigrade", 
		"unicorn",
		"vole",  
		"walrus",
		"yak", "zebra"]
		
	grammar_test["color"] = ["#tone# #baseColor#"]
	grammar_test["tone"] = ["dark", "light", "pale"]
		
	grammar_test["object"] = ["bell", "candle", "anchor", "pen", "quill", "piston",
		"bullet", "knife", "saber", "anvil", "keg", "pump", "hammer"]
		
	grammar_test["barObject"] = ["#object#", "#animal#"]
	grammar_test["bar"] = ["The #object.capitalize# and #animal.capitalize#",
		"The #barObject.capitalize# and #barObject.capitalize#",
		"The #baseColor.capitalize# #animal.capitalize#", 
		"The #tone.capitalize# #animal.capitalize#"]
		
	grammar_test["baseColor"] = ["red", "orange", "yellow", "green", "blue", "indigo", "violet", "purple",
		"pink", "chartreuse", "crimson", "veridian", "ochre", "brown", "black", "white", "gray",
		"tan", "ashen", "lilac", "rose"]
	grammar_test["colors"] = ["#baseColor# and #baseColor#"]
	
	grammar_test["mansName"] = ["Joe", "Mike", "Aaron", "Ben", "Brad", "Chet", "Carl"]
	
	grammar_test["womansName"] = ["Abby", "Betty", "Chrissy", "Delilah", "Emily"]
	
	grammar_test["personsName"] = ["#mansName#", "#womansName#"]
	
	grammar_test["namedBar"] = ["#personsName#'s Bar",
		"#personsName#'s Bar and Grill",
		"#personsName#'s Pub",
		"#personsName# and #personsName#'s Bar"]
	
	# Create our grammar
	var grammar = Tracery.Grammar.new( grammar_test )

	# Use our custom random number generator
	grammar.set_rng(rng)
	
	# Add the english modifiers
	grammar.add_modifiers(Tracery.UniversalModifiers.get_modifiers())
	
	# Flatten / generate a couple of sentences
	#for i in range( 0, 5 ):
		#var sentence = grammar.flatten("#sentence#")
		#print(sentence)
		#
	#for i in range( 0, 25 ):
		#var sentence = grammar.flatten("#bar#")
		#print(sentence)
		
	for i in range( 0, 25 ):
		var sentence = grammar.flatten("#namedBar#")
		print(sentence)
		

	#for i in range( 0, 5 ):
		#var sentence = grammar.flatten("#colors#")
		#print(sentence)
