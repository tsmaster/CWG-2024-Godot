class_name Highway
extends Node


# data exported
class HighwayPoint:
	var lat_lon: Map.LatLon
	# degrees, CCW from East
	var heading: float
	var speed_limit: float
	
# internal information about stretches of highway
class HighwayLegData:
	var lat_lon: Map.LatLon
	# in miles
	var start_distance_from_beginning: float
	# in miles
	var end_distance_from_beginning: float
	# in miles per hour
	var speed_limit_following: float
	# in miles
	var leg_distance: float
	
# a list of HighwayLegData 
var legs:Array = []

func _init(filename:String):
	print("loading highway filename ", filename)
	var full_filename = "res://Highways/JSON/" + filename
	if not FileAccess.file_exists(full_filename):
		print("Error: missing file ", filename)
		return
	var file = FileAccess.open(full_filename, FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	for leg in json_data["legs"]:
		var leg_data = HighwayLegData.new()
		var leg_start_lat = leg["start_lat_lon"]["lat"]
		var leg_start_lon = leg["start_lat_lon"]["lon"]
		leg_data.lat_lon = Map.LatLon.new(leg_start_lat, leg_start_lon)
		var start_cum_dist = leg["cum_dist_mi"]
		leg_data.start_distance_from_beginning = start_cum_dist
		var leg_dist = leg["leg_dist_mi"]
		leg_data.end_distance_from_beginning = start_cum_dist + leg_dist
		legs.append(leg_data)
		#print("appended leg ", leg_data)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getTotalDistance() -> float:
	var leg = legs[-1] as HighwayLegData
	return leg.end_distance_from_beginning

func evalPoint(distance: float) -> HighwayPoint:
	var out: HighwayPoint = HighwayPoint.new()
	
	if distance <= 0:
		# special case for beginning
		var first_leg:HighwayLegData = legs[0]
		out.lat_lon = first_leg.lat_lon
		var next_leg:HighwayLegData = legs[1]
		out.heading = BdgMath.lat_lon_bearing_deg(first_leg.lat_lon, next_leg.lat_lon)

		return out
	
	if distance >= getTotalDistance():
		# special case for end
		var last_leg:HighwayLegData = legs[-1]
		out.lat_lon = last_leg.lat_lon
		var prev_leg:HighwayLegData = legs[-2]
		out.heading = BdgMath.lat_lon_bearing_deg(prev_leg.lat_lon, last_leg.lat_lon)

		return out
	
	# todo search for distance, interpolate
	var leg_index := -1
	
	for i in len(legs):
		var leg:HighwayLegData = legs[i]
		if ((leg.start_distance_from_beginning <= distance) and
			(leg.end_distance_from_beginning > distance)):
				leg_index = i
				break
				
	assert(leg_index != -1)
	var leg:HighwayLegData = legs[leg_index]
	var start_lat = leg.lat_lon.lat
	var start_lon = leg.lat_lon.lon
	
	var leg_start_dist = leg.start_distance_from_beginning
	var leg_end_dist = leg.end_distance_from_beginning
	
	var next_leg:HighwayLegData = legs[leg_index + 1]
	var end_lat = next_leg.lat_lon.lat
	var end_lon = next_leg.lat_lon.lon
	
	var interp_lat = BdgMath.map(distance, leg_start_dist, leg_end_dist, start_lat, end_lat)
	var interp_lon = BdgMath.map(distance, leg_start_dist, leg_end_dist, start_lon, end_lon)

	out.lat_lon = Map.LatLon.new(interp_lat, interp_lon)
	
	# TODO
	out.heading = BdgMath.lat_lon_bearing_deg(leg.lat_lon, next_leg.lat_lon)
	
	return out

func totalLength() -> float:
	# todo pick out distance of last point
	return 0.0
