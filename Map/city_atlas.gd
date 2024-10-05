extends Node
class_name CityAtlas

const TILE_DATA_DICT_FILENAME : String  = "res://Map/Tiles/tileGrid.json"

var tile_dict: Dictionary = {}

var city_list: Array = []

var city_key_to_city_index: Dictionary = {}


func makeCityKey(city_short_name: String, state_abbr: String) -> String:
	var csn = city_short_name.to_lower()
	var sa = state_abbr.to_lower()
	return sa+"|"+csn
	
func addCityDict(city_short_name: String, state_abbr: String, city_dict: Dictionary) -> int:
	var city_key = makeCityKey(city_short_name, state_abbr)
	city_list.append(city_dict)
	var city_index = len(city_list) -1
	city_key_to_city_index[city_key] = city_index
	return city_index

func makeLatLonGridTileKey(lat_lon: Map.LatLon) -> String:
	var lat_i = floori(lat_lon.lat)
	var lon_i = floori(lat_lon.lon)
	var s:String = "lat " + str(lat_i) + " lon " + str(lon_i)
	return s

func loadCities() -> void:
	var file = FileAccess.open(TILE_DATA_DICT_FILENAME, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	for d in data:
		var readTileDict = data[d]
		var tileLatLon = Map.LatLon.new(readTileDict.lat, readTileDict.lon)
		var tileLatLonString = makeLatLonGridTileKey(tileLatLon)
		var local_tile_dict : Dictionary = {}
		local_tile_dict['cities'] = []
		
		for c_pair in readTileDict.cities:
			var city_info_dict:Dictionary = c_pair[1]
			if city_info_dict.is_navigable:
				print(city_info_dict.city_name)
				local_tile_dict.cities.append(city_info_dict)
				addCityDict(city_info_dict.short_city_name, city_info_dict.state_abbr, city_info_dict)
			
		if len(local_tile_dict.cities) > 0:
			print("lat ", readTileDict.lat, " lon ", readTileDict.lon)
			tile_dict[tileLatLonString] = local_tile_dict
			
		
	
func findCityIndex(short_city_name:String, state_abbr:String) -> int :
	var key = makeCityKey(short_city_name, state_abbr)
	if not (key in city_key_to_city_index):
		return -1
	return city_key_to_city_index[key]

func getCityObject(short_city_name:String, state_abbr:String) -> Dictionary:
	var city_index = findCityIndex(short_city_name, state_abbr)
	return getCityObjectByIndex(city_index)
	
func getCityObjectByIndex(city_index: int) -> Dictionary:
	assert((city_index >= 0) and (city_index < len(city_list)))
	return city_list[city_index]
	
