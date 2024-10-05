extends Node2D

@export var bdg_screen : Node
@export var title_screen : Node
@export var menu_screen : Node
@export var map_screen : Node
@export var about_screen : Node

enum MenuState {
	START,
	BDG_SCREEN,
	TITLE_SCREEN,
	MENU_SCREEN,
	MAP_SCREEN,
	ABOUT_SCREEN,
}

var menuState := MenuState.START

# Called when the node enters the scene tree for the first time.
func _ready():
	menuState = MenuState.START
	bdg_screen.visible = true
	title_screen.visible = false
	menu_screen.visible = false
	menu_screen.propagate_call("set_visible", [false])
	map_screen.visible = false
	map_screen.propagate_call("set_visible", [false])
	
	about_screen.propagate_call("set_visible", [false])

	menuState = MenuState.BDG_SCREEN
	bdg_screen.showsplash()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bigdicegameslogo_done():
	setState(MenuState.TITLE_SCREEN)

func _on_carswithgunstitle_done():
	setState(MenuState.MENU_SCREEN)

func setState(newState:MenuState):
	print ("setting state" + str(newState))
	bdg_screen.visible = false
	title_screen.visible = false
	menu_screen.visible = false
	menu_screen.propagate_call("set_visible", [false])
	map_screen.propagate_call("set_visible", [false])
	about_screen.propagate_call("set_visible", [false])
	
	menuState = newState
	
	match newState:
		MenuState.TITLE_SCREEN:
			title_screen.showsplash()
		MenuState.MENU_SCREEN:
			menu_screen.visible = true
			menu_screen.propagate_call("set_visible", [true])
		MenuState.MAP_SCREEN:
			map_screen.propagate_call("set_visible", [true])
			map_screen.begin()
		MenuState.ABOUT_SCREEN:
			about_screen.showsplash()
			
			
	


func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://Screens/MainMenuScreens/NewGameScene.tscn")

func _on_load_game_button_pressed():
	get_tree().change_scene_to_file("res://Screens/MainMenuScreens/LoadGameScene.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://Screens/MainMenuScreens/OptionsScene.tscn")

func _on_about_button_pressed():
	setState(MenuState.ABOUT_SCREEN)

func _on_map_button_pressed():
	setState(MenuState.MAP_SCREEN)

func _on_map_done():
	setState(MenuState.MENU_SCREEN)


func _on_exit_button_pressed():
	get_tree().quit()
