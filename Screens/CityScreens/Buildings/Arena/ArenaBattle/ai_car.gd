extends CharacterBody2D
class_name AiCar2D

@export var waypoint_node: Node2D

enum AiMode {
	MODE_PATROL,
	MODE_PURSUE,
	MODE_SNIPE,
	MODE_FLEE
}

var ai_mode:AiMode = AiMode.MODE_PATROL

var wheel_base = 70 # centimeters, front/back between wheels
var steering_angle = 15 # degrees, max wheel turn

var engine_power : float = 700

var friction = -55
var drag = -0.06

var braking:float = -450
var max_speed_reverse = 250

var slip_speed = 400
var traction_fast = 2.5
var traction_slow = 10

var acceleration := Vector2.ZERO
var steer_direction: float = 0.0 # ??? "amount the wheels are turned"

var chosen_waypoint = null

const WAYPOINT_PROXIMITY = 100
const SNIPE_DISTANCE = 1500
const FLEE_DISTANCE = 3000
const SHOT_PERIOD: float = 1.5

var rng:RandomNumberGenerator

var player_car: Node2D

var shot_time: float = 0.0

var bullet_class = preload("res://sprites/bullet-mg.tscn")

var hp = 2

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	player_car = get_parent().find_child("Player Car")
# 
func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	
func get_input():
	if ai_mode == AiMode.MODE_PATROL:
		doPatrol()
	elif ai_mode == AiMode.MODE_PURSUE:
		doPursue()
	elif ai_mode == AiMode.MODE_SNIPE:
		doSnipe()
	elif ai_mode == AiMode.MODE_FLEE:
		doFlee()
		

func doPatrol():
	if canSeePlayerCar():
		print("see player car")
		chosen_waypoint = null
		ai_mode = AiMode.MODE_PURSUE
		return
		
	if chosen_waypoint == null:
		chooseWaypoint()
	else:
		var vector_to_waypoint = chosen_waypoint - position
		var dir_to_waypoint = vector_to_waypoint.angle()
		var dist_to_waypoint = vector_to_waypoint.length()
		if dist_to_waypoint < WAYPOINT_PROXIMITY:
			chooseWaypoint()
			
	if chosen_waypoint == null:
		return
		
	goToLocation(chosen_waypoint, WAYPOINT_PROXIMITY)
	
func goToLocation(target_position: Vector2, target_distance: float):	
	var vect_to_target:Vector2 = target_position - position
	var dir_to_target = vect_to_target.angle()
	var dir_to_target_deg = BdgMath.radians_to_degrees(dir_to_target)
	var dot_product = transform.x.dot(vect_to_target.normalized())
	
	var forward_point = position + transform.x
	var forward_dir = transform.x.angle()
	var forward_dir_deg = BdgMath.radians_to_degrees(forward_dir)
	
	var rel_dir_deg = dir_to_target_deg - forward_dir_deg
	while rel_dir_deg < -180:
		rel_dir_deg += 360
	while rel_dir_deg > 180:
		rel_dir_deg -= 360
		
	var clamped_rel_dir_deg = BdgMath.clamp(rel_dir_deg, -steering_angle, steering_angle)		
	
	clamped_rel_dir_deg *= 0.1	
	
	steer_direction = clamped_rel_dir_deg
	
	if dot_product > -0.1:
		acceleration = transform.x * engine_power
	else:
		acceleration = transform.x * engine_power * 0.5
		if rel_dir_deg > 0:
			steer_direction = steering_angle
		else:
			steer_direction = -steering_angle

func doPursue():
	if not canSeePlayerCar():
		ai_mode = AiMode.MODE_PATROL
		return
	goToLocation(player_car.position, 0)
	if canShoot():
		var bullet_obj = bullet_class.instantiate()
		get_tree().root.add_child(bullet_obj)
		gBulletMgr.addBullet(BulletMgr.BulletTeam.TEAM_ENEMY, position, (player_car.position - position), bullet_obj)
		shot_time = getTimeNow()
		
func canShoot() -> bool:
	return getTimeNow() - shot_time >= SHOT_PERIOD
	
func getTimeNow() -> float:
	return Time.get_ticks_msec() / 1000.0
	
func doSnipe():
	if not canSeePlayerCar():
		ai_mode = AiMode.MODE_PATROL
		return
	else:
		goToLocation(player_car.position, SNIPE_DISTANCE)
	
func doFlee():
	if not canSeePlayerCar():
		ai_mode = AiMode.MODE_PATROL
		return
	else:
		goToLocation(player_car.position, FLEE_DISTANCE)
	
		
func chooseWaypoint():
	var seen_waypoints:Array = []
	for wp:Node2D in waypoint_node.get_children():
		print("considering ", wp.name)
		var vector_to_waypoint = wp.position - position
		if vector_to_waypoint.length() < WAYPOINT_PROXIMITY:
			print("too close")
			continue
		if canSee(wp.position):
			print("can see wp")
			seen_waypoints.append(wp)
		else:
			print("occluded")
	if len(seen_waypoints) > 0:
		var chosen_index = rng.randi_range(0, len(seen_waypoints) - 1)
		print("choosing index ", chosen_index)
		chosen_waypoint = seen_waypoints[chosen_index].position	
	
func canSee(target: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position,
			target)
	query.collide_with_areas = true
	var collision = space.intersect_ray(query)
	if collision:
		#print("collided")
		return false
	else:
		#print("no collision")
		return true
	
func canSeePlayerCar() -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position,
			player_car.position)
	query.collide_with_areas = true
	var collision = space.intersect_ray(query)
	if collision.collider == player_car:
		return true
	else:
		return false
	
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	
	
func calculate_steering(delta):
	# calc "bicycle" wheel positions
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# move wheels forward
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	# find the new direction vector
	var new_heading = rear_wheel.direction_to(front_wheel)
	
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	
	# set the velocity and rotation
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
		#velocity = new_heading * velocity.length()
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	#velocity = new_heading * velocity.length()
	rotation = new_heading.angle()
	
func takeDamage():
	hp -= 1
	
func isDead():
	return hp <= 0
	
