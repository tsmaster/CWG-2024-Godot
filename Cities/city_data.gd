extends Node
class_name CityData

@export var city_name:String
@export var state_name:String

var lat_lon:Map.LatLon

func getLatLon() -> Map.LatLon:
	return lat_lon
