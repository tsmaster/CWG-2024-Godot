extends Node2D

@onready var voronoi_polygons = $VoronoiPolygons
@onready var bridson_points = $BridsonPoints
@onready var path_lines = $PathLines

var city_dict:Dictionary = {}
var city_object:CityObject

func _ready():
	print("Race Track Visualization")

	city_dict = gCityAtlas.getCityObject(gGameMgr.cur_city_short_name, gGameMgr.cur_state_abbr)
	city_object = CityObject.new(city_dict.seed)
	
	var rng = RandomNumberGenerator.new()
	rng.set_seed(city_object.getInternalSeed(city_dict.seed, CityObject.CITY_SEED.CITY_RACETRACK_SEED))
	
	var nodes:Array = makeBridson(rng)
	var delaunayFactory = Delaunay.new(get_viewport_rect())
	for n in nodes:
		delaunayFactory.add_point(n)
		
	var triangles = delaunayFactory.triangulate()
	var sites = delaunayFactory.make_voronoi(triangles)
	for s in sites:
		var new_polygon: Polygon2D = Polygon2D.new()
		new_polygon.color = makeRandomColor(rng)
		new_polygon.polygon = s.polygon
		voronoi_polygons.add_child(new_polygon)
	var min_steps: int = 10
	var max_steps: int = 20
	var loop = findLoop(sites, min_steps, max_steps, rng)
	print("LOOP: ", loop)
	print("looplen: ", len(loop))
	drawLoop(sites, loop)

func drawLoop(sites, loop):
	
	var EASE:float = 0.9
	
	var new_curve = Curve2D.new()

	var curved_new_line = Line2D.new()
	curved_new_line.default_color = Color(0.2, 0.2, 0.2)
	curved_new_line.closed = true
	
	for i:int in range(len(loop)):
		var j = (i + 1) % len(loop) 
		var k = (j + 1) % len(loop)
	
		var c1:Vector2 = sites[loop[i]].center
		var c2:Vector2 = sites[loop[j]].center
		var c3:Vector2 = sites[loop[k]].center
		
		var m12: Vector2 = (c2 + c1) / 2
		
		var new_line = Line2D.new()
		new_line.add_point(c1)
		new_line.add_point(c2)
		
		new_curve.add_point(m12, m12 - c1, c2 - m12)
		
	curved_new_line.points = new_curve.get_baked_points()
	path_lines.add_child(curved_new_line)
		
	
func makeRandomColor(rng: RandomNumberGenerator) -> Color:
	var red = rng.randf_range(0.0, 1.0)
	var green = rng.randf_range(0.0, 1.0)
	var blue = rng.randf_range(0.0, 1.0)
	return Color(red, green, blue)

const STEP_LEN = 400.0
const CELL_WIDTH = sqrt(STEP_LEN)
var ANGLE_STEP = BdgMath.degrees_to_radians(10.0)

func makeKey(point: Vector2, left:float, top:float) -> Vector2i:
	var ix:int = floori((point.x - left) / CELL_WIDTH)
	var iy:int = floori((point.y - top) / CELL_WIDTH)
	return Vector2i(ix, iy)
	
func doesPointCollide(point: Vector2, left:float, top:float, grid:Dictionary) -> bool:
	var center_key:Vector2i = makeKey(point, left, top)
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var new_x_idx = center_key.x + dx
			var new_y_idx = center_key.y + dy
			var new_key = Vector2i(new_x_idx, new_y_idx)
			if new_key in grid:
				var other_point:Vector2 = grid[new_key]
				var delta:Vector2 = other_point - point
				var dist_squared = delta.length_squared()
				if (dist_squared <= STEP_LEN*STEP_LEN):
					return true
	return false
	
func makeBridson(rng: RandomNumberGenerator) -> Array:
	var left = 0.0
	var viewport_size = get_viewport().size
	var right = viewport_size.x
	var top = 0.0
	var bottom = viewport_size.y
	
	var grid:Dictionary = {}
	
	var center:Vector2 = Vector2((right+left) / 2.0, (top + bottom) / 2.0)
	
	var key:Vector2i = makeKey(center, left, top)
	grid[key] = center
	addPoint(center)
	
	var open_list:Array = [center]
	var closed_list:Array = []
	
	while len(open_list) > 0:
		var p:Vector2 = open_list.pop_front()
		var theta0 = 0.0
		var thetaOff = rng.randf_range(0, 2*PI)
		
		while theta0 < 2 * PI:
			var theta = theta0 + thetaOff
			var dx = STEP_LEN * cos(theta)
			var dy = STEP_LEN * sin(theta)
			var nx = dx + p.x
			var ny = dy + p.y
			if ((nx > left) and
				(nx < right) and
				(ny > top) and
				(ny < bottom)):
				var new_point = Vector2(nx, ny)
				var new_key:Vector2i = makeKey(new_point, left, top)
				if not (doesPointCollide(new_point, left, top, grid)):
					open_list.append(new_point)
					grid[new_key] = new_point
					addPoint(new_point)
					#print("Adding point ", new_point)
			theta0 += ANGLE_STEP
		closed_list.append(p)
	print("placed ", len(closed_list), " nodes")
	return closed_list
	
func addPoint(point: Vector2) -> void:
	var polygon = Polygon2D.new()
	
	var polygon_verts = PackedVector2Array()
	var s = 5
	polygon_verts.append(Vector2(-s,s))
	polygon_verts.append(Vector2(s,s))
	polygon_verts.append(Vector2(s,-s))
	polygon_verts.append(Vector2(-s,-s))
	polygon.polygon = polygon_verts
	polygon.color = Color.WHITE
	polygon.position = point
	#add_child(polygon)
	#delaunay.add_point(point)
	
	bridson_points.add_child(polygon)
	
func findLoop(sites: Array, min_steps: int, max_steps: int, rng: RandomNumberGenerator):
	# pick a random starting index
	var starting_index = rng.randi_range(0, len(sites))
	starting_index = 0
	
	var starting_list = [starting_index]
	
	# call a function to recursively find a loop that is in the min to max steps
	var out_array = findLoopPath(sites, starting_list, min_steps, max_steps, rng)
	
	return out_array
	
func findSiteIndex(site: int, site_array:Array) -> int:
	for site_index in range(len(site_array)):
		var s = site_array[site_index]
		if s == site:
			return site_index
	return -1
	
func myShuffle(deck: Array, rng: RandomNumberGenerator) -> void:
	for i in range(len(deck)):
		var j = rng.randi_range(0, len(deck) - 1)
		if j == i:
			continue
		var temp = deck[i]
		deck[i] = deck[j]
		deck[j] = temp

			
func findLoopPath(sites: Array, path_so_far: Array, min_steps: int, max_steps: int, rng: RandomNumberGenerator):
	var adj_sites:Array = findAdjacentSiteIndices(sites, path_so_far[-1])
	# TODO shuffle using my RNG
	#adj_sites.shuffle()
	myShuffle(adj_sites, rng)
	for adj_site_index in adj_sites:
		var new_path = path_so_far.duplicate()
		new_path.append(adj_site_index)
		
		if (adj_site_index == path_so_far[0]):
			if (len(new_path) < min_steps):
				# TOO SHORT, fail
				continue
			elif ((len(new_path) >= min_steps) and
				(len(new_path) <= max_steps)):
				# valid solution
				return new_path
			else:
				# how do we get here?
				continue
		if adj_site_index in path_so_far:
			# revisiting the path
			continue

		var return_dist = findDist(sites, path_so_far[0], adj_site_index)
		var max_return_dist = (max_steps - len(new_path)) * STEP_LEN
		if return_dist > max_return_dist:
			# TOO FAR, fail
			continue

		# seems good
		var out = findLoopPath(sites, new_path, min_steps, max_steps, rng)
		if out == null:
			# didn't find a solution
			continue
		else:
			return out
	return null

func findDist(sites:Array, start_index: int, end_index: int) -> float:
	var s1:Delaunay.VoronoiSite = sites[start_index]
	var s2:Delaunay.VoronoiSite = sites[end_index]
	var c1:Vector2 = s1.center
	var c2:Vector2 = s2.center
	
	return (c2 - c1).length()

func findAdjacentSiteIndices(sites: Array, site_index: int) -> Array:
	var out_array = []

	var site:Delaunay.VoronoiSite = sites[site_index]	
	
	for edge:Delaunay.VoronoiEdge in site.neighbours:
		var adj_site:Delaunay.VoronoiSite = edge.other
		var adj_index = getIndex(sites, adj_site)
		assert(adj_index != -1)
		out_array.append(adj_index)
	return out_array
		
func getIndex(sites: Array, adj_site:Delaunay.VoronoiSite) -> int:
	for idx:int in range(len(sites)):
		var s:Delaunay.VoronoiSite = sites[idx]
		if (s.center - adj_site.center).length_squared() < 1:
			return idx
	return -1
