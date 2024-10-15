extends Node2D

@onready var title = $BaseUiScene/VBoxContainer/Title
@onready var label = $BaseUiScene/VBoxContainer/Label


# TODO these buttons will be procedurally created

@onready var arena_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Arena Button"
@onready var race_track_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/RaceTrack Button"
@onready var car_showroom_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Car Showroom Button"
@onready var factory_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Factory Button"
@onready var weapons_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Weapons Button"
@onready var bar_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Bar Button"
@onready var truck_stop_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/TruckStop Button"
@onready var fix_it_shoppe_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/FixIt Shoppe Button"
@onready var salvage_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Salvage Button"
@onready var bus_depot_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Bus Depot Button"
@onready var blimp_field_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Blimp Field Button"
@onready var hospital_button = $"BaseUiScene/VBoxContainer/Activity TabContainer/Buildings/Hospital Button"

var city_object: CityObject

enum Buildings {
	BLDG_ARENA,
	BLDG_RACE_TRACK,
	BLDG_CAR_SHOWROOM,
	BLDG_FACTORY,
	BLDG_WEAPONS_SHOP,
	BLDG_BAR,
	BLDG_TRUCK_STOP,
	BLDG_REPAIR_SHOP,
	BLDG_SALVAGE_YARD,
	BLDG_BUS_DEPOT,
	BLDG_BLIMP_FIELD,
	BLDG_HOSPITAL,
	BLDG_HIGHWAY_CLUB,
	BLDG_POST_OFFICE,
	BLDG_GOVERNMENT_CENTER,
}


func _ready():
	city_object = gCityAtlas.getCityObject(gGameMgr.cur_city_short_name, gGameMgr.cur_state_abbr)
	title.text = "City: " + city_object.city_name + ", " + gGameMgr.cur_state_abbr.to_upper()
	label.text = "Population %d\nTODO: this list of buttons will be populated based on procgen content" % city_object.getPopulation()
	
	bar_button.text = city_object.getBarName()
	arena_button.text = city_object.getArenaName()
	race_track_button.text = city_object.getRaceTrackName()
	
	bindButton(arena_button, _on_arena_button_pressed)
	bindButton(race_track_button, _on_race_track_button_pressed)
	bindButton(car_showroom_button, _on_car_showroom_button_pressed)
	bindButton(factory_button, _on_factory_button_pressed)
	bindButton(weapons_button, _on_weapons_shop_button_pressed)
	bindButton(bar_button, _on_bar_button_pressed)
	bindButton(truck_stop_button, _on_truck_stop_button_pressed)
	bindButton(fix_it_shoppe_button, _on_repair_button_pressed)
	bindButton(salvage_button, _on_salvage_button_pressed)
	bindButton(bus_depot_button, _on_bus_depot_button_pressed)
	bindButton(blimp_field_button, _on_blimp_field_button_pressed)
	bindButton(hospital_button, _on_hospital_button_pressed)
	
func _on_ok_button_pressed():
	pass # Replace with function body.


func _on_cancel_button_pressed():
	pass #get_tree().change_scene_to_file("res://main.tscn")

func bindButton(button: Button, callback: Callable):
	button.pressed.connect(callback)
	
func _on_arena_button_pressed():
	print("Arena")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/ArenaScene.tscn")
	
func _on_race_track_button_pressed():
	print("Race Track")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/RaceTrack/RaceTrackScene.tscn")

func _on_car_showroom_button_pressed():
	print("Car Showroom")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/CarShowRoom/CarShowRoomScene.tscn")
	
func _on_factory_button_pressed():
	print("Factory")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Factory/FactoryScene.tscn")

func _on_weapons_shop_button_pressed():
	print("Weapons Shop")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/WeaponsShop/WeaponsShopScene.tscn")
	
func _on_bar_button_pressed():
	print("Bar")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Bar/BarScene.tscn")

func _on_truck_stop_button_pressed():
	print("Truck Stop")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/TruckStop/TruckStopScene.tscn")
	
func _on_repair_button_pressed():
	print("Repair Shop")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/RepairShop/RepairShopScene.tscn")

func _on_salvage_button_pressed():
	print("Salvage")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/SalvageYard/SalvageYardScene.tscn")
	
func _on_bus_depot_button_pressed():
	print("Bus Depot")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/BusDepot/BusDepotScene.tscn")

func _on_blimp_field_button_pressed():
	print("Blimp Field")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/BlimpField/BlimpFieldScene.tscn")
	
func _on_hospital_button_pressed():
	print("Hospital")
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Hospital/HospitalScene.tscn")
