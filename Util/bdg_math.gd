class_name BdgMath


static func map(in_val: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	var t = (in_val - in_min) / (in_max - in_min)
	return t * (out_max - out_min) + out_min

static func degrees_to_radians(degrees : float) -> float :
	return map(degrees, 0, 360, 0.0, 2.0 * PI)
	
static func radians_to_degrees(radians: float) -> float :
	return map(radians, 0, 2 * PI, 0.0, 360.0)
	
static func clamp(in_val: float, in_min: float, in_max: float) -> float:
	if in_val < in_min:
		return in_min
	if in_val > in_max:
		return in_max
	return in_val
	
static func floor_to_mult(in_val: float, mult_val: int) -> int :
	return floori(in_val / mult_val) * mult_val
	
static func ceil_to_mult(in_val: float, mult_val: int) -> int :
	var v:int = floori(in_val / mult_val) * mult_val
	if v < in_val:
		return v + mult_val
	return v
	
const EARTH_RADIUS_KM := 6371
const EARTH_DIAM_KM := 2 * EARTH_RADIUS_KM
const EARTH_CIRC_KM := PI * EARTH_DIAM_KM

const EARTH_RADIUS_MI := 3956
const EARTH_DIAM_MI := 2 * EARTH_RADIUS_MI
const EARTH_CIRC_MI := PI * EARTH_DIAM_MI

static func haversine_deg_to_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
	"""
	from https://stackoverflow.com/questions/4913349/haversine-formula-in-python-bearing-and-distance-between-two-gps-points
	
	Calculate the great circle distance in kilometers between two points 
	on the earth (specified in decimal degrees)
	"""
	
	# convert decimal degrees to radians 
	var lon1_rad = degrees_to_radians(lon1)
	var lat1_rad = degrees_to_radians(lat1)
	var lon2_rad = degrees_to_radians(lon2)
	var lat2_rad = degrees_to_radians(lat2)

	# haversine formula 
	var delta_lon = lon2_rad - lon1_rad
	var delta_lat = lat2_rad - lat1_rad
	
	var a = sin(delta_lat/2.0)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon/2)**2
	var c = 2 * asin(sqrt(a)) 
	return c * EARTH_RADIUS_KM

static func haversine_deg_to_miles(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
	"""
	from https://stackoverflow.com/questions/4913349/haversine-formula-in-python-bearing-and-distance-between-two-gps-points
	
	Calculate the great circle distance in miles between two points 
	on the earth (specified in decimal degrees)
	"""
	
	# convert decimal degrees to radians 
	var lon1_rad = degrees_to_radians(lon1)
	var lat1_rad = degrees_to_radians(lat1)
	var lon2_rad = degrees_to_radians(lon2)
	var lat2_rad = degrees_to_radians(lat2)

	# haversine formula 
	var delta_lon = lon2_rad - lon1_rad
	var delta_lat = lat2_rad - lat1_rad
	
	var a = sin(delta_lat/2.0)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon/2)**2
	var c = 2 * asin(sqrt(a)) 
	return c * EARTH_RADIUS_MI
	
static func degree_to_miles_at_latitude_degrees(lon: float) ->Array[float]:
	""" returns one degree of lat, lon in miles (n/s, e/w) for a given latitude"""
	var lon_rad = degrees_to_radians(lon)

	# according to https://www.usgs.gov/faqs/how-much-distance-does-a-degree-minute-and-second-cover-your-maps
	# at 38N latitude (n/s, doesn't matter)
	# 1 degree longitude is 54.6 mi
	# 1 degree latitude is 69 mi
	const one_degree_equator := EARTH_CIRC_MI / 360.0
	const one_degree_lat := one_degree_equator
	var one_degree_lon = cos(lon_rad) * one_degree_equator

	return [one_degree_lat, one_degree_lon]

static func degree_to_km_at_latitude_degrees(lon: float) -> Array[float]:
	""" returns one degree of lat, lon in km (n/s, e/w) for a given latitude"""
	var lon_rad = degrees_to_radians(lon)

	const one_degree_equator = EARTH_CIRC_KM / 360.0
	const one_degree_lat = one_degree_equator
	var one_degree_lon = cos(lon_rad) * one_degree_equator

	return [one_degree_lat, one_degree_lon]

static func mile_to_degrees_at_latitude_degrees(lat: float) -> Array[float] :
	""" returns one mile of lat, lon in degrees (n/s, e/w) for a given latitude"""
	var lat_rad = degrees_to_radians(lat)
	
	# according to https://www.usgs.gov/faqs/how-much-distance-does-a-degree-minute-and-second-cover-your-maps
	# at 38N latitude (n/s, doesn't matter)
	# 1 degree longitude is 54.6 mi
	# 1 degree latitude is 69 mi
	const one_degree_equator := EARTH_CIRC_MI / 360.0
	const one_degree_lat := one_degree_equator
	var one_degree_lon = cos(lat_rad) * one_degree_equator

	return [1.0 / one_degree_lat, 1.0 / one_degree_lon]
	
static func km_to_degrees_at_latitude_degrees(lat: float) -> Array[float]:
	""" returns one km of lat, lon in degrees (n/s, e/w) for a given latitude"""
	var lat_rad = degrees_to_radians(lat)

	const one_degree_equator = EARTH_CIRC_KM / 360.0
	const one_degree_lat = one_degree_equator
	var one_degree_lon = cos(lat_rad) * one_degree_equator

	return [1.0 / one_degree_lat, 1.0 / one_degree_lon]
	
static func lat_lon_bearing_deg(lat_lon_1: Map.LatLon, lat_lon_2: Map.LatLon) -> float:
	""" returns bearing in degrees"""
	
	var lat_a_rad:float = degrees_to_radians(lat_lon_1.lat)
	var lon_a_rad:float = degrees_to_radians(lat_lon_1.lon)
	
	var lat_b_rad:float = degrees_to_radians(lat_lon_2.lat)
	var lon_b_rad:float = degrees_to_radians(lat_lon_2.lon)

	var delta_lon_rad:float = lon_b_rad - lon_a_rad

	var x = cos(lat_b_rad) * sin(delta_lon_rad)
	var y = cos(lat_a_rad) * sin(lat_b_rad) - sin(lat_a_rad) * cos(lat_b_rad) * cos(delta_lon_rad)

	var bearing_rad = atan2(x, y)
	var bearing_deg = radians_to_degrees(bearing_rad)

	return bearing_deg
	
  
