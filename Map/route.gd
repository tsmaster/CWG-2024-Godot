class_name Route

extends Node

# highways is an array of Highway
var _highways:Array = []
var _is_forward_by_leg:Array = []
var _start_distances_by_leg:Array = []
var _end_distances_by_leg:Array = []

func _init(highways: Array):
	_highways = []
	_is_forward_by_leg = []
	_start_distances_by_leg = []
	_end_distances_by_leg = []
	
	var cum_distance := 0.0
	
	for i in range(len(highways)):
		var pair = highways[i]
		assert(pair[0] is Highway)
		assert(pair[1] is bool)
		var hwy: Highway = pair[0] as Highway
		
		_highways.append(hwy)
		_is_forward_by_leg.append(pair[1])
		_start_distances_by_leg.append(cum_distance)
		cum_distance += hwy.getTotalDistance()
		_end_distances_by_leg.append(cum_distance)

# returns [LatLon, heading]
func evalPoint(distance: float) -> Highway.HighwayPoint:
	# todo find which leg this distance corresponds to
	# find whether that leg is forward or backward
	# measure distance within the leg using the leg's evalPoint
	
	if distance >= _end_distances_by_leg[-1]:
		distance = _end_distances_by_leg[-1]
	if distance < 0:
		distance = 0
	
	var leg_index = -1
	
	for i in len(_highways):
		if ((distance >= _start_distances_by_leg[i]) and
			(distance <= _end_distances_by_leg[i])):
			leg_index = i
			break
			
	assert (leg_index != -1)
	
	var leg_distance = distance - _start_distances_by_leg[leg_index]
	
	var hwy:Highway = _highways[leg_index]
	
	if !_is_forward_by_leg[leg_index]:
		leg_distance = hwy.getTotalDistance() - leg_distance

	var out_hwy_point:Highway.HighwayPoint = hwy.evalPoint(leg_distance)

	if !_is_forward_by_leg[leg_index]:
		out_hwy_point.heading += 180.0
	return out_hwy_point
	
func getTotalDistance() -> float:
	return _end_distances_by_leg[-1]
	
static func getRoute(start_city_name: String, start_state_name: String, end_city_name: String, end_state_name: String):
	if ((start_city_name == "bremerton")	 and
		(start_state_name == "wa") and 
		(end_city_name == "boston") and
		(end_state_name == "ma")):
			return Route.new([[Highway.new('bremerton-wa-seattle-wa.json'), true],
				[Highway.new('bellevue-wa-seattle-wa.json'), false],
				[Highway.new('bellevue-wa-ellensburg-wa.json'), true],
				[Highway.new('ellensburg-wa-vantage-wa.json'), true],
				[Highway.new('spokane-wa-vantage-wa.json'), false],
				[Highway.new('butte-mt-spokane-wa.json'), false],
				[Highway.new('billings-mt-butte-mt.json'), false],
				[Highway.new('billings-mt-chicago-il.json'), true],
				[Highway.new('buffalo-ny-chicago-il.json'), false],
				[Highway.new('buffalo-ny-syracuse-ny.json'), true],
				[Highway.new('albany-ny-syracuse-ny.json'), false],
				[Highway.new('albany-ny-boston-ma.json'), true]])


	# temp
	return [[Highway.new('Highways/bremerton-wa-seattle-wa.json'), true],
	 		[Highway.new('Highways/bellevue-wa-seattle-wa.json'), false],
	 		[Highway.new('Highways/bellevue-wa-ellensburg-wa.json'), true],
	 		[Highway.new('Highways/ellensburg-wa-vantage-wa.json'), true],
	 		[Highway.new('Highways/spokane-wa-vantage-wa.json'), false],
	 		[Highway.new('Highways/butte-mt-spokane-wa.json'), false],
	 		[Highway.new('Highways/billings-mt-butte-mt.json'), false],
	 		[Highway.new('Highways/billings-mt-chicago-il.json'), true],
	 		[Highway.new('Highways/buffalo-ny-chicago-il.json'), false],
	 		[Highway.new('Highways/buffalo-ny-syracuse-ny.json'), true],
	 		[Highway.new('Highways/albany-ny-syracuse-ny.json'), false],
	 		[Highway.new('Highways/albany-ny-boston-ma.json'), true]]
	
