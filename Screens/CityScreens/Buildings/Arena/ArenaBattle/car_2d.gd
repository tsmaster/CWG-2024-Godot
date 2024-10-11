extends CharacterBody2D


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
var steer_direction # ??? "amount the wheels are turned"

# 
func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	
func get_input():
	var turn = Input.get_axis("car_2d_left", "car_2d_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("car_2d_accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("car_2d_brake"):
		acceleration = transform.x * braking
		
	if Input.is_key_pressed(KEY_C):
		position = Vector2(400,300)	
		
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
	
	
	
