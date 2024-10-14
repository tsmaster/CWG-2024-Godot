extends Node2D

@onready var caption = $BaseUiScene/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match gGameMgr.last_arena_result:
		GameMgr.ArenaResult.RESULT_WIN:
			caption.text = "You totally win"
		GameMgr.ArenaResult.RESULT_LOSS:
			caption.text = "You were eliminated. Come back again."
		GameMgr.ArenaResult.RESULT_ESCAPE:
			caption.text = "You escaped with your life and (some of?) your car."
		_:
			caption.text = "I don't know. Maybe you won?"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ok_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/ArenaScene.tscn")

func _on_cancel_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/ArenaScene.tscn")
