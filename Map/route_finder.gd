extends Node
class_name RouteFinder

"""
A singleton that can be asked to find a Route (see route.gd)
"""

signal routeSearchComplete

# array of start city index, end city index, highway object
var highways: Array = []

# keyed by city index, contents are arrays of [dest city index, highway index, is forward]
var adjacency_dict: Dictionary = {}

func calcHeuristic(start_city_index, end_city_index) -> float:
	var start_city_obj = gCityAtlas.getCityObjectByIndex(start_city_index)
	var end_city_obj = gCityAtlas.getCityObjectByIndex(end_city_index)
	
	var start_lat_lon:Map.LatLon = Map.LatLon.new(start_city_obj.lat, start_city_obj.lon)
	var end_lat_lon:Map.LatLon = Map.LatLon.new(end_city_obj.lat, end_city_obj.lon)
	
	var dist = BdgMath.haversine_deg_to_miles(start_lat_lon.lat, start_lat_lon.lon, end_lat_lon.lat, end_lat_lon.lon)
	
	return dist

func findRoute(startCity:String, startStateAbbr:String, endCity:String, endStateAbbr:String) -> Route:
	"""
	async method (coroutine), signals routeSearchComplete
	"""

	var start_index = gCityAtlas.findCityIndex(startCity, startStateAbbr)
	var end_index = gCityAtlas.findCityIndex(endCity, endStateAbbr)
	
	print("beginning search from ", start_index, " to ", end_index)
	
	var open_list: Array = [start_index]
	var best_dist_dict: Dictionary = {start_index: 0.0}
	var best_prev_index: Dictionary = {start_index: -1}
	
	var queue: Array = []
	queue.append([calcHeuristic(start_index, end_index), 0.0, start_index])
	
	while len(queue) > 0:
		if end_index in best_prev_index:
			break
		
		var queue_element = queue.pop_front()
		var this_elapsed_distance: float = queue_element[1]
		var this_city_index:int = queue_element[2]
		
		for adj_record in adjacency_dict[this_city_index]:
			var adj_city_index: int = adj_record[0]
			var highway_index: int = adj_record[1]
			var highway_obj: Highway = highways[highway_index][2]
			
			var step_length = highway_obj.getTotalDistance()
			
			var accum_dist = this_elapsed_distance + step_length
			
			if ((not (adj_city_index in best_dist_dict)) or 
				(accum_dist < best_dist_dict[adj_city_index])):
				var new_heuristic = calcHeuristic(adj_city_index, end_index)
				best_dist_dict[adj_city_index] = accum_dist
				best_prev_index[adj_city_index] = this_city_index
				if adj_city_index != end_index:
					var new_node = [new_heuristic, accum_dist, adj_city_index]
					queue.append(new_node)
					queue.sort()
		
	var out_city_list:Array = [end_index]
	var cur_city:int = end_index
	
	while true:
		var prev = best_prev_index[cur_city]
		if prev == -1:
			break
		out_city_list.push_front(prev)
		cur_city = prev
		
	print("Found City List: ", out_city_list)
	
	for ci in out_city_list:
		var city_object = gCityAtlas.getCityObjectByIndex(ci)
		print (city_object.city_name, " ", city_object.state_abbr)
	
	var out_highway_list: Array = []
	for list_index in range(len(out_city_list) - 1):
		var leg_start_city_index = out_city_list[list_index]
		var leg_end_city_index = out_city_list[list_index + 1]
		
		# look up highway by start, end city indices
		var leg = getHighwayLeg(leg_start_city_index, leg_end_city_index)
		
		var leg_highway_index:int = leg[0]
		var leg_forward:bool = leg[1]
		assert(leg_highway_index >= 0)
		var hwy_obj: Highway = highways[leg_highway_index][2]
		out_highway_list.append([hwy_obj, leg_forward])
		print("leg ", leg)
	
	await get_tree().create_timer(0.1).timeout
	print("completed search")
	return Route.new(out_highway_list)
	
func getHighwayLeg(start_city_index: int, end_city_index: int) -> Array:
	for a in adjacency_dict[start_city_index]:
		var a_end_index = a[0]
		if a_end_index == end_city_index:
			return [a[1], a[2]]
	return [-1, false]
	
func addHighway(startCity:String, startStateAbbr:String, endCity:String, endStateAbbr:String, highwayJsonFilename: String):
	var highway_object = Highway.new(highwayJsonFilename)
	
	var start_city_index = gCityAtlas.findCityIndex(startCity, startStateAbbr)
	var end_city_index = gCityAtlas.findCityIndex(endCity, endStateAbbr)

	const VERIFY_ENDPOINTS: bool = false
	
	if VERIFY_ENDPOINTS:
		assert (start_city_index >= 0)
		assert (end_city_index >= 0)
	else:
		if start_city_index == -1:
			print("warning: start city not found: ", startCity, " ", startStateAbbr)
			return
		if end_city_index == -1:
			print("warning: end city not found: ", endCity, " ", endStateAbbr)
			return
	
	highways.append([start_city_index, end_city_index, highway_object])	
	var new_highway_index = len(highways) - 1
	print ("new highway ", new_highway_index, " from ", startCity," ", startStateAbbr, " ", start_city_index)
	print ("  to ", endCity, " ", endStateAbbr, " ", end_city_index)
	
	addAdjacencies(start_city_index, end_city_index, new_highway_index)

func addAdjacencies(start_city_index: int, end_city_index:int, new_highway_index:int) -> void:
	addAdjacencyOneWay(start_city_index, end_city_index, new_highway_index, true)
	addAdjacencyOneWay(end_city_index, start_city_index, new_highway_index, false)

func addAdjacencyOneWay(start_city_index: int, end_city_index:int, new_highway_index:int, is_forward:bool) -> void:
	if not (start_city_index in adjacency_dict):
		adjacency_dict[start_city_index] = []
	adjacency_dict[start_city_index].append([end_city_index, new_highway_index, is_forward])
	
func loadHighways():
	for filename in DirAccess.get_files_at("res://Highways/JSON/"):
		print ("loading highway ", filename)
		var base = filename.split(".")[0]
		var parts = base.split("-")
		var c1=parts[0]
		var s1=parts[1]
		var c2=parts[2]
		var s2=parts[3]
		addHighway(c1, s1, c2, s2, filename)
		
		
