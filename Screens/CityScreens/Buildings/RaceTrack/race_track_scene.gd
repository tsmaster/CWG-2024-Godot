extends Node2D

@onready var title = $BaseUiScene/VBoxContainer/Title
@onready var label = $BaseUiScene/VBoxContainer/Label
@onready var texture_rect = $"BaseUiScene/VBoxContainer/Activity TabContainer/Info/TextureRect"
@onready var texture_rect_2 = $"BaseUiScene/VBoxContainer/Activity TabContainer/Info/TextureRect2"

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
		
	var texture:Texture2D = texture_rect.texture
	var image:Image = Image.new()
	var image_data:PackedByteArray = []
	image_data.resize(256 * 256 * 3)
	
	for x in range(0, 256):
		for y in range(0, 256):
			var idx:int = (y * 256 + x ) * 3
			image_data[idx] = x
			image_data[idx+1] = y
			var dx:int = 128 - x
			var dy:int = 128 - y
			var dist:float = sqrt(dx*dx + dy*dy)
			if (dist > 128):
				image_data[idx+2] = 0
			else:
				image_data[idx+2] = 255
	
	image = Image.create_from_data(256, 256, false, Image.FORMAT_RGB8, image_data)
	
	texture_rect.texture = ImageTexture.create_from_image(image)

	var image2:Image = Image.create(256, 256, false, Image.FORMAT_RGB8)
	for x in range(0, 256):
		for y in range(0, 256):
			#var c:Color = Color(x/256.0, y/256.0, 0.5)
			
			var angle = atan2(128 - y, 128 - x)
			var angle_norm = angle / (2*PI)
			if angle_norm < 0:
				angle_norm += 1
			var c:Color = Color.from_hsv(angle_norm, 1.0, 1.0)
			image2.set_pixel(x, y, c)
			
	texture_rect_2.texture = ImageTexture.create_from_image(image2)
	
	# todo when updating, keep image and ImageTexture around, 
	# set_pixels as necessary in the image, 
	# call image_texture.update()
	# https://docs.godotengine.org/en/stable/classes/class_imagetexture.html#class-imagetexture-method-update
	

func _on_ok_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/CityOverviewScene.tscn")

func _on_cancel_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/CityOverviewScene.tscn")


func _on_race_map_button_pressed():
	get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/RaceTrack/race_track_vis.tscn")
