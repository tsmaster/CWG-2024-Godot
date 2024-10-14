extends CharacterBody2D
class_name PlayerCar2D


var wheel_base = 70 # centimeters, front/back between wheels
var steering_angle = 15 # degrees, max wheel turn

var engine_power : float = 900

var friction = -55
var drag = -0.06

var braking:float = -450
var max_speed_reverse = 250

var slip_speed = 400
var traction_fast = 2.5
var traction_slow = 10

var acceleration := Vector2.ZERO
var steer_direction = 0# ??? "amount the wheels are turned"

var bullet_class = preload("res://sprites/bullet-mg.tscn")

var hp = 6
var starting_hp = hp

var steer_relative: bool = false

var shot_time: float = 0.0
# 
func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	
func get_input():
	if steer_relative:
		var turn = Input.get_axis("car_2d_left", "car_2d_right")
		steer_direction = turn * deg_to_rad(steering_angle)
	else:
		doSteerAbsolute()
	if Input.is_action_pressed("car_2d_accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("car_2d_brake"):
		acceleration = transform.x * braking
		
	if Input.is_action_just_pressed("car_2d_shoot"):
		print("bang")
		shoot()
		
	if Input.is_key_pressed(KEY_C):
		position = Vector2(400,300)	
		
func doSteerAbsolute():
	var desired_angle_deg:float = -100.0
	if Input.is_action_pressed("car_2d_steer_abs_west"):
		desired_angle_deg = 180.0
	elif Input.is_action_pressed("car_2d_steer_abs_east"):
		desired_angle_deg = 0.0
	elif Input.is_action_pressed("car_2d_steer_abs_north"):
		desired_angle_deg = 270.0
	elif Input.is_action_pressed("car_2d_steer_abs_south"):
		desired_angle_deg = 90.0

	if desired_angle_deg < 0:
		return
		
	#print("desired angle: ", desired_angle_deg)
	
	var ew_axis = Input.get_axis("car_2d_steer_abs_east", "car_2d_steer_abs_west")
	var ns_axis = Input.get_axis("car_2d_steer_abs_north", "car_2d_steer_abs_south")
	
	var throttle = sqrt(ew_axis * ew_axis + ns_axis * ns_axis)
	
	acceleration = Vector2.ZERO
	if throttle > 0.5: 
		acceleration = transform.x * engine_power * BdgMath.map(throttle, 0.5, 1.0, 0.0, 1.0)
	elif throttle < 0.25:
		acceleration = transform.x * braking * BdgMath.map(throttle, 0.25, 0.0, 0, 1)
	
	var desired_angle_rad = BdgMath.degrees_to_radians(desired_angle_deg)
	
	var relative_heading = desired_angle_rad - rotation
	if relative_heading < -PI:
		relative_heading += 2 * PI
	if relative_heading > PI:
		relative_heading -= 2 * PI
	var steering_angle_rad = BdgMath.degrees_to_radians(steering_angle)
	var clamped_heading = BdgMath.clamp(relative_heading, -steering_angle_rad, steering_angle_rad)
	steer_direction = clamped_heading
		
func shoot():
	var bullet_obj = bullet_class.instantiate()
	get_tree().root.add_child(bullet_obj)
	gBulletMgr.addBullet(BulletMgr.BulletTeam.TEAM_PLAYER, position, transform.x, bullet_obj)
	shot_time = gGameMgr.getTimeNow()

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
	
	
