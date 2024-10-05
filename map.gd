class_name Map
extends Node2D

@onready var size_1_tiles = $CanvasLayer/size_1_tiles
@onready var size_5_tiles = $CanvasLayer/size_5_tiles
@onready var size_15_tiles = $CanvasLayer/size_15_tiles
@onready var size_45_tiles = $CanvasLayer/size_45_tiles
@onready var size_90_tiles = $CanvasLayer/size_90_tiles
@onready var size_360_tiles = $CanvasLayer/size_360_tiles
@onready var canvas_layer = $CanvasLayer

@onready var tiles_sz_1 = $CanvasLayer/tiles_sz_1
@onready var tiles_sz_5 = $CanvasLayer/tiles_sz_5
@onready var tiles_sz_15 = $CanvasLayer/tiles_sz_15
@onready var tiles_sz_45 = $CanvasLayer/tiles_sz_45
@onready var tiles_sz_90 = $CanvasLayer/tiles_sz_90
@onready var tiles_sz_360 = $CanvasLayer/tiles_sz_360

@onready var city_labels = $CanvasLayer/CityLabels

@onready var car_sprite = $CanvasLayer/car_sprite

const TILE_DATA_DICT_FILENAME = "res://Map/Tiles/tileGrid.json"

signal done

var route:Route
var route_progress:float
var route_speed: float = 0.0 # miles per second
var route_top_speed: float = 120.0 # miles per second
var route_acc: float = 5.0
var route_start_zoom: float = 0.3
var route_mid_zoom: float = 2.0

# TODO move into its own script file
class LatLon:
	var lat:float
	var lon:float
	
	func _init(lat_deg: float, lon_deg: float):
		lat = lat_deg
		lon = lon_deg
		
	func _to_string():
		return "%f, %f" % [lat, lon]

var center_lon := -120.74
var center_lat := 47.55
var center_lat_lon: LatLon
var start_miles_per_pixel := 0.44
var miles_per_pixel = start_miles_per_pixel

var cur_city_name: String = "bremerton"
var cur_state_abbr: String = "wa"

var dest_city_name: String = ""
var dest_state_abbr: String = ""

var car_lat_lon: LatLon = LatLon.new(0, 0)

"""
Washington
center 47.55 -120.74
miles per pixel 0.44
"""

"""
Western Washington
center 47.6143979927581 -122.931601927039
miles per pixel 0.12358378395976
"""

"""
All US
center 37.0661838719384 -96.7812661139634
miles per pixel 2.37210947624747
"""

"""
Northeastern Seaboard
center 45.0484392400513 -80.8854731654034
miles per pixel 1.67089926776626
"""

class ViewPointPreset:
	var location_lat_lon: LatLon
	var miles_per_pixel: float
	
	func _init(lat_lon: LatLon, mpp: float):
		location_lat_lon = lat_lon
		miles_per_pixel = mpp
		
var viewpointWashington = ViewPointPreset.new(LatLon.new(47.55,-120.74), 0.44)
var viewpointWesternWashington = ViewPointPreset.new(LatLon.new(47.61,-122.93), 0.12)
var viewpointAllUS = ViewPointPreset.new(LatLon.new(37.07, -96.78), 2.37)
var viewpointNortheast = ViewPointPreset.new(LatLon.new(45.05, -80.89), 1.67)
var window_size: Vector2

var is_active: bool = false

var is_mouse_captured: bool = false

var capture_lat_lon: LatLon

var degree_ranges: Dictionary

# 2 dimensional dict, 1st layer is sz, 2nd maps a name to a Sprite2D
# this is for SVG sprite info, tile_data_dict is for JSON info
var tile_dict: Dictionary = {}
# maps name to a LatLon
var lat_lon_dict: Dictionary = {}

const size_list: Array = [1, 5, 15, 45, 90, 360]

var layer_dict: Dictionary = {}

var tile_label_dict: Dictionary = {}

# tile info keyed by a LatLon pair (of ints?), with info about cities (and 
# eventually highways?)
var tile_data_dict: Dictionary = {}

func applyPreset(preset: ViewPointPreset):
	center_lat_lon = preset.location_lat_lon
	miles_per_pixel = preset.miles_per_pixel
	car_lat_lon = center_lat_lon
	
# Called when the node enters the scene tree for the first time.
func _ready():
	window_size = get_viewport().size
	
	print("window size ", window_size)
	
	applyPreset(viewpointWesternWashington)
	#applyPreset(viewpointNortheast)
	
	car_sprite.position = Vector2(window_size[0] / 2.0, window_size[1] / 2.0)
	
	print("initial LatLon ", center_lat_lon)
	
	layer_dict[1] = tiles_sz_1
	layer_dict[5] = tiles_sz_5
	layer_dict[15] = tiles_sz_15
	layer_dict[45] = tiles_sz_45
	layer_dict[90] = tiles_sz_90
	layer_dict[360] = tiles_sz_360
	
	for sz_index in len(size_list):
		var sz = size_list[sz_index]
		tile_dict[sz] = {}
		
	tile_data_dict = loadTiles(TILE_DATA_DICT_FILENAME)
	

func calcFades() -> Array[float]:
	var center_lat_lon: LatLon = getCenterLatLon()
	#print("Center LatLon ", center_lat_lon)
	var degrees_per_mile: Array[float] = BdgMath.mile_to_degrees_at_latitude_degrees(center_lat_lon.lat)
	#print("dpm: ", degrees_per_mile)
	var deg_per_mile_lon = degrees_per_mile[1]
	
	var deg_per_pixel_lon = deg_per_mile_lon * miles_per_pixel
	
	const target_tile_pixel_width = 400.0
	
	var widths:Array[float]
	widths.resize(len(size_list))
	
	for sz_index in len(size_list):
		var sz = size_list[sz_index]
		var rendered_tile_width = sz / deg_per_pixel_lon
		widths[sz_index] = rendered_tile_width
		#print ("width for sz(%d deg): %f px" % [sz, rendered_tile_width])

	#print("widths: ", widths)		
	var alphas:Array[float]
	alphas.resize(len(size_list))
	
	if widths[0] > target_tile_pixel_width:
		alphas[0] = 1.0
	elif widths[-1] < target_tile_pixel_width:
		alphas[-1] = 1.0
	else:
		for i in range(len(size_list)-1):
			var j = i+1
			var sz_i = size_list[i]
			var sz_j = size_list[j]
			var w_i = widths[i]
			var w_j = widths[j]
			if ((w_i <= target_tile_pixel_width) and
				(target_tile_pixel_width < w_j)):
				var t = BdgMath.map(target_tile_pixel_width, w_i, w_j, 0, 1)
				alphas[i] = 1.0
				alphas[j] = t
				break
	
	return alphas
	
func calcFadesDebug() -> Array[float]:
	var alphas:Array[float]
	alphas.resize(len(size_list))

	alphas[1] = 1.0
	
	return alphas
	
func applyFades(alphas: Array[float]) -> void:
	for sz_index in len(size_list):
		var sz = size_list[sz_index]
		var alpha = alphas[sz_index]
		var layer:CanvasModulate = layer_dict[sz]
		for c in layer_dict[sz].get_children():
			var tile:Sprite2D = c as Sprite2D
			tile.self_modulate = Color(1.0, 1.0, 1.0, alpha)

func calcDegreeRangesForScreenFromPoint(screen_point: Vector2, c_lat_lon: LatLon, miles_per_pixel: float) -> Dictionary:
	var out = {}
	
	var degrees_per_mile: Array[float] = BdgMath.mile_to_degrees_at_latitude_degrees(center_lat)
	var deg_per_mile_lat = degrees_per_mile[0]
	var deg_per_mile_lon = degrees_per_mile[1]
	
	var screen_dist_left_in_miles:float = screen_point[0] * miles_per_pixel
	var screen_dist_right_in_miles:float = (window_size[0] - screen_point[0]) * miles_per_pixel
	var screen_dist_up_in_miles:float = screen_point[1] * miles_per_pixel
	var screen_dist_down_in_miles:float = (window_size[1] - screen_point[1]) * miles_per_pixel
	
	var screen_width_left_in_degrees = deg_per_mile_lon * screen_dist_left_in_miles
	var screen_width_right_in_degrees = deg_per_mile_lon * screen_dist_right_in_miles
	var screen_height_up_in_degrees = deg_per_mile_lat * screen_dist_up_in_miles
	var screen_height_down_in_degrees = deg_per_mile_lat * screen_dist_down_in_miles
	
	out["lon_left"] = c_lat_lon.lon - screen_width_left_in_degrees
	out["lon_right"] = c_lat_lon.lon + screen_width_right_in_degrees
	out["lat_top"] = c_lat_lon.lat + screen_height_up_in_degrees
	out["lat_bot"] = c_lat_lon.lat - screen_height_down_in_degrees
	
	return out
	
func calcDegreeRangesForScreen(c_lat_lon: LatLon, miles_per_pixel: float) -> Dictionary:
	var cx: float = window_size[0] / 2.0
	var cy: float = window_size[1] / 2.0

	return calcDegreeRangesForScreenFromPoint(Vector2(cx, cy), c_lat_lon, miles_per_pixel)

func positionTile(degreeRange: Dictionary, tile_size: int, tile_left_bot_lat_lon: LatLon) -> Dictionary :
	var out = {}
	
	# TODO replace out dictionary with a POD struct
	var tile_left_lon: int = int(tile_left_bot_lat_lon.lon)
	var tile_bot_lat: int = int(tile_left_bot_lat_lon.lat)

	out["tile_left"] = BdgMath.map(tile_left_lon,
		degreeRange["lon_left"], degreeRange["lon_right"],
		0, window_size[0])

	out["tile_right"] = BdgMath.map(tile_left_lon + tile_size,
		degreeRange["lon_left"], degreeRange["lon_right"],
		0, window_size[0])
	
	out["tile_bot"] = BdgMath.map(tile_bot_lat,
		degreeRange["lat_bot"], degreeRange["lat_top"],
		window_size[1], 0)

	out["tile_top"] = BdgMath.map(tile_bot_lat + tile_size,
		degreeRange["lat_bot"], degreeRange["lat_top"],
		window_size[1], 0)
	
	return out

func makeTileFilename(sz: int, lon: int, lat: int) -> String:
	# OLD fn looks like "res://Map/Tiles/tile_sz_1_lat_49_lon_-125.jpg"
	# OLD fn looks like "res://Map/Tiles/tile_sz_1_lat_49_lon_-125.png"
	# fn looks like "res://Map/Tiles/tile_sz_1_lat_49_lon_-125.svg"
	var basename = "tile_sz_"+str(sz)+"_lat_"+str(lat)+"_lon_"+str(lon)+".svg"
	var fn = "res://Map/Tiles/" + basename
	return fn
	
func loadTile(sz: int, lon: int, lat: int):
	var fn = makeTileFilename(sz, lon, lat)
	if not ResourceLoader.exists(fn):
		return null
	var s = Sprite2D.new()
	s.texture = load(fn)
	return s
	
func tileExists(sz: int, lon: int, lat: int) -> bool:
	var fn = makeTileFilename(sz, lon, lat)
	return ResourceLoader.exists(fn)
	
func enterCity() -> void:
	if route == null:
		print("entering city ", cur_city_name, " ", cur_state_abbr)
		gGameMgr.cur_city_short_name = cur_city_name
		gGameMgr.cur_state_abbr = cur_state_abbr
		
		get_tree().change_scene_to_file("res://Screens/CityScreens/CityOverviewScene.tscn")
		return
	print("cannot enter city, as we're on a roadtrip")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta_seconds):
	if Input.is_action_just_pressed("ui_cancel"):
		done.emit()
	if Input.is_action_pressed("Pan_Map_North"):
		offsetView(delta_seconds, 0)
	if Input.is_action_pressed("Pan_Map_South"):
		offsetView(-delta_seconds, 0)
	if Input.is_action_pressed("Pan_Map_East"):
		offsetView(0, delta_seconds)
	if Input.is_action_pressed("Pan_Map_West"):
		offsetView(0, -delta_seconds)
	if Input.is_action_just_pressed("Map_Enter_City"):
		enterCity();
	
	if route:	
		route_speed = BdgMath.clamp(route_speed + route_acc * delta_seconds, 0.0, route_top_speed)
		route_progress += delta_seconds * route_speed
		var point:Highway.HighwayPoint = route.evalPoint(route_progress)
		var pos:LatLon = point.lat_lon
		var angle:float = point.heading
		#print("pos ", pos)
		#print("angle ", angle)
		
		var progress_frac = route_progress / route.getTotalDistance()
		
		var route_zoom = 1.0
		
		if progress_frac < 0.5:
			route_zoom = BdgMath.map(progress_frac, 0.0, 0.5, route_start_zoom, route_mid_zoom)
		else:
			route_zoom = BdgMath.map(progress_frac, 0.5, 1.0, route_mid_zoom, route_start_zoom)
			
		miles_per_pixel = route_zoom
		
		car_lat_lon = pos
		car_sprite.rotation_degrees = angle
		centerMapOnLatLon(pos)
		
		if route_progress >= route.getTotalDistance():
			route = null
			cur_city_name = dest_city_name
			cur_state_abbr = dest_state_abbr
	

func getCenterLatLon() -> LatLon:
	var screen_center: Vector2 = Vector2(window_size[0] / 2.0, window_size[1] / 2.0)
	return screen_pos_to_lat_lon(screen_center)
	
func offsetView(deltaLat: float, deltaLon:float) -> void:
	#print("offsetting view ", deltaLat, " ", deltaLon)
	var center_lat_lon = getCenterLatLon()

	var degrees_per_mile: Array[float] = BdgMath.mile_to_degrees_at_latitude_degrees(center_lat)
	var deg_per_mile_lat = degrees_per_mile[0]
	var deg_per_mile_lon = degrees_per_mile[1]
	
	var deg_per_pixel_lat = deg_per_mile_lat * miles_per_pixel
	var deg_per_pixel_lon = deg_per_mile_lon * miles_per_pixel
	
	const offset_pixels: float = 200.0
	var new_lat_lon = LatLon.new(
		center_lat_lon.lat + deltaLat * deg_per_pixel_lat * offset_pixels,
		center_lat_lon.lon + deltaLon * deg_per_pixel_lon * offset_pixels)
	
	var screen_center: Vector2 = Vector2(window_size[0] / 2.0, window_size[1] / 2.0)
	
	degree_ranges = calcDegreeRangesForScreen(new_lat_lon, miles_per_pixel)
	layout()
	
func placeAndScaleTile(tile: Sprite2D, tile_size: int, tile_left_bot: LatLon, degree_range: Dictionary) -> void :
		#print ("in placeAndScaleTile")
		#print ("in placeAndScaleTile: dr: ", degree_range)
		#print ("in placeAndScaleTile: ts: ", tile_size)
		#print ("in placeAndScaleTile: tl: ", tile_left_bot.lon)
		#print ("in placeAndScaleTile: tb: ", tile_left_bot.lat)
	var tile_info = positionTile(degree_range, tile_size, tile_left_bot)
		#print ("tileInfo: ", tile_info)
	var x = (tile_info["tile_left"] + tile_info["tile_right"]) / 2.0
	var y = (tile_info["tile_bot"] + tile_info["tile_top"]) / 2.0
	tile.position = Vector2(x,y)
	var scale_x = (tile_info["tile_right"] - tile_info["tile_left"]) / tile.texture.get_width()
	var scale_y = (tile_info["tile_bot"] - tile_info["tile_top"]) / tile.texture.get_height()
	tile.scale = Vector2(scale_x, scale_y)

func prelayout():
	purgeCityLabels()
	var fades: Array = calcFades()
	for sz_index in len(size_list):
		var sz = size_list[sz_index]
		if fades[sz_index] > 0:
			populateTiles(sz)
		else:
			purgeTiles(sz)
	applyFades(fades)
	populateCityLabels()
			
func layout():
	prelayout()
	for sz_index in len(size_list):
		var sz = size_list[sz_index]
		for c_name in tile_dict[sz]:
			var tile:Sprite2D = tile_dict[sz][c_name] as Sprite2D
			var latlon: LatLon = lat_lon_dict[c_name]
			placeAndScaleTile(tile, sz, latlon, degree_ranges)
	car_sprite.position = lat_lon_to_screen_pos(car_lat_lon)

func populateTiles(size: int) -> void:
	var lon_left = degree_ranges["lon_left"]
	var lon_right = degree_ranges["lon_right"]
	var lat_top = degree_ranges["lat_top"]
	var lat_bottom = degree_ranges["lat_bot"]
	
	var wanted_names:Array[String] = []
	var have_names:Array[String] = []
	
	var wanted_data:Dictionary = {}
	
	var layer:CanvasModulate = layer_dict[size]
	
	for c_lon:int in range(BdgMath.floor_to_mult(lon_left, size), BdgMath.ceil_to_mult(lon_right, size) + 1, size):
		for c_lat:int in range(BdgMath.floor_to_mult(lat_bottom, size), BdgMath.ceil_to_mult(lat_top, size) + 1, size):
			if tileExists(size, c_lon, c_lat):
				var name:String = "tile_sz_" + str(size) + "_lat_" + str(c_lat)+ "_lon_"+str(c_lon)
				wanted_names.append(name)
				wanted_data[name] = [size, c_lat, c_lon]
				lat_lon_dict[name] = LatLon.new(c_lat, c_lon)

	for c in layer.get_children():
		if not(c.name in wanted_names):
			layer.remove_child(c)
			c.queue_free()
			tile_dict[size].erase(c.name)
			lat_lon_dict.erase(c.name)
		else:
			have_names.append(c.name)
			
	for name:String in wanted_names:
		if name in have_names:
			continue
		var data = wanted_data[name]
		var tile_size: int = data[0]
		var c_lat: int = data[1]
		var c_lon: int = data[2]
	
		var also_tile:Sprite2D = loadTile(tile_size, c_lon, c_lat)
		if also_tile != null:
			also_tile.name = name
			#print("adding tile ", also_tile.name)
			layer.add_child(also_tile)
			var lat_lon = lat_lon_dict[name]
			tile_dict[tile_size][name] = also_tile
			placeAndScaleTile(also_tile, tile_size, lat_lon, degree_ranges)
		
func purgeTiles(size: int) -> void:
	var layer:CanvasModulate = layer_dict[size]
	for c:Node2D in layer.get_children():
		layer.remove_child(c)
		c.queue_free()
	for c_name:String in tile_dict[size]:
		tile_dict[size].erase(c_name)
		lat_lon_dict.erase(c_name)
	tile_dict[size].clear()
	
func populateCityLabels() -> void:
	var label_settings:LabelSettings = LabelSettings.new()
	label_settings.font_color = Color.BLACK
	label_settings.outline_color = Color.RED
	
	for city_data in getCitiesOnScreen():
		var city_name = city_data.city_name
		var city_lat = city_data.lat
		var city_lon = city_data.lon
		var city_lat_lon: LatLon = LatLon.new(city_lat, city_lon)
		
		var label: Label = Label.new()
		label.name = "city_label_" + city_data.short_city_name
		label.text = city_name
		label.label_settings = label_settings
		
		var label_position: Vector2 = lat_lon_to_screen_pos(city_lat_lon)
		label.set_position(label_position)
		city_labels.add_child(label)
	
	
	
func purgeCityLabels() -> void:
	for label in city_labels.get_children():
		city_labels.remove_child(label)

func begin():
	degree_ranges = calcDegreeRangesForScreen(center_lat_lon, miles_per_pixel)
	#print("initial deg range", degree_ranges)

	layout()
	
	is_active = true
	
	gCityAtlas.loadCities()
	gRouteFinder.loadHighways()
	
	#route = Route.getRoute("bremerton", "wa", "boston", "ma")
	route = null
	route_progress = 0
	
func centerMapOnLatLon(lat_lon: LatLon) -> void:
	center_lat_lon = lat_lon
	degree_ranges = calcDegreeRangesForScreen(center_lat_lon, miles_per_pixel)
	layout()
	
func screen_pos_to_lat_lon(screen_pos:Vector2) -> LatLon:
	var outLatLon = LatLon.new(
		BdgMath.map(screen_pos[1], 0, window_size[1], degree_ranges["lat_top"], degree_ranges["lat_bot"]),
		BdgMath.map(screen_pos[0], 0, window_size[0], degree_ranges["lon_left"], degree_ranges["lon_right"]))
	return outLatLon
	
func lat_lon_to_screen_pos(lat_lon:LatLon) -> Vector2:
	var x = BdgMath.map(lat_lon.lon, degree_ranges.lon_left, degree_ranges.lon_right, 0, window_size[0])
	var y = BdgMath.map(lat_lon.lat, degree_ranges.lat_top, degree_ranges.lat_bot, 0, window_size[1])
	return Vector2(x,y)
	
func _unhandled_input(event):
	if not is_active:
		return
		
	if event is InputEventMouseButton:
		print("mouse button event", event)
		var mb_event = event as InputEventMouseButton
		var button = mb_event.button_index
		var mask = mb_event.button_mask
		print("button: ", button)
		print("mask: ", mask)
		
		if button == MOUSE_BUTTON_LEFT:
			if mb_event.double_click:
				print("double click at ", mb_event.global_position)
				var double_click_lat_lon = screen_pos_to_lat_lon(mb_event.global_position)
				var dest_city = findDestinationCityFromLatLon(double_click_lat_lon)
				print("new destination: ", dest_city.short_city_name, " ", dest_city.state_abbr)
				var new_route = await gRouteFinder.findRoute(cur_city_name, cur_state_abbr, dest_city.short_city_name, dest_city.state_abbr)
				print("got new route: ", new_route)
				
				if (new_route != null):
					route = new_route
					route_progress = 0.0
					dest_city_name = dest_city.short_city_name
					dest_state_abbr = dest_city.state_abbr
				
			elif mb_event.is_pressed():
				print("pressed at ", mb_event.global_position)
				is_mouse_captured = true
				capture_lat_lon = screen_pos_to_lat_lon(mb_event.global_position)
				degree_ranges = calcDegreeRangesForScreenFromPoint(mb_event.global_position,
					capture_lat_lon, miles_per_pixel)
				
			else:
				print("released at ", mb_event.global_position)
				degree_ranges = calcDegreeRangesForScreenFromPoint(mb_event.global_position,
					capture_lat_lon, miles_per_pixel)
				print("new degree ranges: ", degree_ranges)
				layout()
				is_mouse_captured = false
		elif button == MOUSE_BUTTON_WHEEL_UP:
			if mb_event.pressed:
				print("mouse wheel up")
				miles_per_pixel *= 0.9
				var center_lat_lon = screen_pos_to_lat_lon(mb_event.global_position)
				degree_ranges = calcDegreeRangesForScreenFromPoint(mb_event.global_position,
					center_lat_lon, miles_per_pixel)
				layout()
		elif button == MOUSE_BUTTON_WHEEL_DOWN:
			if mb_event.pressed:
				print("mouse wheel down")
				miles_per_pixel *= 1.1
				var center_lat_lon = screen_pos_to_lat_lon(mb_event.global_position)
				degree_ranges = calcDegreeRangesForScreenFromPoint(mb_event.global_position,
					center_lat_lon, miles_per_pixel)
				layout()
		
	elif event is InputEventMouseMotion:
		if is_mouse_captured:
			var mm_event: InputEventMouseMotion = event as InputEventMouseMotion
			var pos_now = mm_event.global_position
			degree_ranges = calcDegreeRangesForScreenFromPoint(mm_event.global_position,
				capture_lat_lon, miles_per_pixel)
			layout()
		pass
	elif event is InputEventKey:
		var k_event = event as InputEventKey
		#print("key event ", k_event)
		if k_event.physical_keycode == KEY_C and k_event.pressed:
			print("centering")
			
			miles_per_pixel = start_miles_per_pixel
			degree_ranges = calcDegreeRangesForScreen(center_lat_lon, miles_per_pixel)
			layout()
			
		if k_event.physical_keycode == KEY_QUOTELEFT and k_event.pressed:
			print("backquote")
			
			var c_lat_lon = getCenterLatLon()
			print("center ", c_lat_lon.lat, " ", c_lat_lon.lon)
			print("miles per pixel ", miles_per_pixel)
		if k_event.physical_keycode == KEY_BRACKETLEFT and k_event.pressed:
			# zoom in
			miles_per_pixel *= 0.9
			var screen_center = Vector2(window_size[0] / 2.0, window_size[1] / 2.0)
			var center_lat_lon = screen_pos_to_lat_lon(screen_center)
			degree_ranges = calcDegreeRangesForScreenFromPoint(screen_center,
				center_lat_lon, miles_per_pixel)
			layout()
			
		if k_event.physical_keycode == KEY_BRACKETRIGHT and k_event.pressed:
			# zoom out
			miles_per_pixel *= 1.1
			var screen_center = Vector2(window_size[0] / 2.0, window_size[1] / 2.0)
			var center_lat_lon = screen_pos_to_lat_lon(screen_center)
			degree_ranges = calcDegreeRangesForScreenFromPoint(screen_center,
				center_lat_lon, miles_per_pixel)
			layout()

func loadTiles(filename: String) -> Dictionary:
	var outDict: Dictionary = {}
	
	var file = FileAccess.open(filename, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	for d in data:
		#print("found data ", d)
		var readTileDict = data[d]
		#print("lat ", readTileDict.lat, " lon ", readTileDict.lon)
		var tileLatLon = LatLon.new(readTileDict.lat, readTileDict.lon)
		var tileLatLonString = makeLatLonGridTileKey(tileLatLon)
		var tileDict = {}
		tileDict['cities'] = []
		
		for c_pair in readTileDict.cities:
			var city_info_dict:Dictionary = c_pair[1]
			if city_info_dict.is_navigable:
				print(city_info_dict.city_name)
				tileDict.cities.append(city_info_dict)
			
		if len(tileDict.cities) > 0:
			print("lat ", readTileDict.lat, " lon ", readTileDict.lon)
			outDict[tileLatLonString] = tileDict
		
	return outDict
	
func makeLatLonGridTileKey(lat_lon: LatLon) -> String:
	var lat_i = floori(lat_lon.lat)
	var lon_i = floori(lat_lon.lon)
	var s:String = "lat " + str(lat_i) + " lon " + str(lon_i)
	return s
	
func getCitiesNearLatLon(lat_lon_center: LatLon, distance_mi: float) -> Array:
	var outArray: Array = []

	var window_degrees = BdgMath.mile_to_degrees_at_latitude_degrees(lat_lon_center.lon)	
	var delta_lat : float = abs(window_degrees[0])
	var delta_lon : float = abs(window_degrees[1])
	
	var left_lon = lat_lon_center.lon - delta_lon
	var right_lon = lat_lon_center.lon + delta_lon
	var top_lat = lat_lon_center.lat + delta_lat
	var bot_lat = lat_lon_center.lat - delta_lat
	
	var left_lon_i = floori(left_lon)
	var right_lon_i = ceili(right_lon)
	
	var bot_lat_i = floori(bot_lat)
	var top_lat_i = ceili(top_lat)

	for lat_iter in range(bot_lat_i, top_lat_i+1)	:
		for lon_iter in range(left_lon_i, right_lon_i + 1):
			var latLonKey:LatLon = LatLon.new(lat_iter, lon_iter)
			var latLonKeyString : String = makeLatLonGridTileKey(LatLon.new(lat_iter, lon_iter))
			
			if latLonKeyString in tile_data_dict:
				var data = tile_data_dict[latLonKeyString]
				for c in data.cities:
					outArray.append(c)
	
	return outArray

func getCitiesOnScreen() -> Array:
	var outArray: Array = []
	
	var lon_left = degree_ranges["lon_left"]
	var lon_right = degree_ranges["lon_right"]
	var lat_top = degree_ranges["lat_top"]
	var lat_bottom = degree_ranges["lat_bot"]
	
	var lon_left_i = floori(lon_left)
	var lon_right_i = ceili(lon_right)
	
	var lat_bot_i = floori(lat_bottom)
	var lat_top_i = ceili(lat_top)

	for lat_iter in range(lat_bot_i, lat_top_i+1)	:
		for lon_iter in range(lon_left_i, lon_right_i + 1):
			var latLonKey:LatLon = LatLon.new(lat_iter, lon_iter)
			var latLonKeyString : String = makeLatLonGridTileKey(LatLon.new(lat_iter, lon_iter))
			
			if latLonKeyString in tile_data_dict:
				var data = tile_data_dict[latLonKeyString]
				for c in data.cities:
					outArray.append(c)
	
	return outArray
	
	
func findDestinationCityFromLatLon(lat_lon: LatLon) -> Dictionary :
	var closest_city:Dictionary = {}
	var closest_dist:float = -1.0
	
	for c in getCitiesOnScreen():
		var city_lat = c.lat
		var city_lon = c.lon
		var city_lat_lon = LatLon.new(city_lat, city_lon)
		var dist_mi = BdgMath.haversine_deg_to_miles(city_lat, city_lon, lat_lon.lat, lat_lon.lon)
		
		if ((closest_dist < 0) or
			(dist_mi < closest_dist)):
			closest_city = c
			closest_dist = dist_mi
	
	return closest_city
