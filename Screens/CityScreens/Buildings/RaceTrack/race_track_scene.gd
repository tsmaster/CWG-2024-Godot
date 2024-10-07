extends Node2D

@onready var title = $BaseUiScene/VBoxContainer/Title
@onready var label = $BaseUiScene/VBoxContainer/Label

var city_dict:Dictionary = {}
var city_object:CityObject

func _ready():
	city_dict = gCityAtlas.getCityObject(gGameMgr.cur_city_short_name, gGameMgr.cur_state_abbr)
	city_object = CityObject.new(city_dict.seed)
	
	title.text = city_dict.city_name + " Race Track"
	
	var rng = RandomNumberGenerator.new()
	rng.set_seed(city_object.getInternalSeed(city_dict.seed, CityObject.CITY_SEED.CITY_RACETRACK_SEED))
	for i in range(10):
		print("r ", i, " : ", rng.randi_range(0, 10))

func _on_ok_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/CityOverviewScene.tscn")

func _on_cancel_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/CityOverviewScene.tscn")


func _on_race_map_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/RaceTrack/race_track_vis.tscn")
