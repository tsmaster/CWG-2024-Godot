extends Node2D

@onready var title = $BaseUiScene/VBoxContainer/Title
@onready var label = $BaseUiScene/VBoxContainer/Label

var city_object:CityObject

func _ready():
	city_object = gCityAtlas.getCityObject(gGameMgr.cur_city_short_name, gGameMgr.cur_state_abbr)
	title.text = city_object.getArenaName()
	
func _on_ok_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/CityOverviewScene.tscn")

func _on_cancel_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/CityOverviewScene.tscn")


func _on_arena_battle_button_pressed() -> void:
	print("going to battle")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/arena_battle.tscn")
