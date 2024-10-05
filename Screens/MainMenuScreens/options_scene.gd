extends Node2D

@onready var resolution_option_button:OptionButton = $"BaseUiScene/VBoxContainer/GridContainer/Resolution OptionButton"
@onready var fullscreen_checkbox:CheckBox = $"BaseUiScene/VBoxContainer/GridContainer/Fullscreen CheckBox"
@onready var vsync_checkbox:CheckBox = $"BaseUiScene/VBoxContainer/GridContainer/VSync CheckBox"
@onready var sound_volume_h_slider = $"BaseUiScene/VBoxContainer/GridContainer/Sound Volume HSlider"
@onready var music_volume_h_slider = $"BaseUiScene/VBoxContainer/GridContainer/Music Volume HSlider"

func _ready():
	# TODO get all valid resolutions
	# populate the list
	
	# Steam popular resolutions:
	
	"""
1280 x 720
1280 x 800
1280 x 1024
1360 x 768
1366 x 768
1440 x 900
1600 x 900
1680 x 1050
1920 x 1080
	"""
	
	#var ds:DisplayServer = DisplayServer.new();
	
	var window_size = DisplayServer.window_get_size()
	
	print("current window size ", window_size)
	
	resolution_option_button.selected = 1
	fullscreen_checkbox.button_pressed = true
	vsync_checkbox.button_pressed = true
	sound_volume_h_slider.value = 65
	music_volume_h_slider.value = 71
	

func _on_ok_button_pressed():
	pass # Replace with function body.

func _on_cancel_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
