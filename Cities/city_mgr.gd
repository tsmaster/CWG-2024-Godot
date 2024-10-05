extends Node
class_name CityMgr

var city_list:Array[CityData]

func load():
	# get from JSON
	pass
	
func findByName(query_name:String) -> Array[CityData]:
	var out_list = []
	
	for c in city_list:
		if c.city_name == query_name:
			out_list.append(c)
	
	return out_list
	
func findByBBox(bbox) -> Array[CityData]:
	var out_list = []
	
	return out_list

func findByLatLonMiles(lat_lon: Map.LatLon, distance_miles: float) -> Array[CityData]:
	var out_list = []
	
	return out_list
	
	
