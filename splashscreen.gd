extends Sprite2D

signal done

@export var timer:Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("UI_Advance"):
		set_done()

func _on_timer_timeout():
	set_done()
	
func showsplash():
	visible = true
	propagate_call("set_visible", [true])
	set_process(true)
	if timer:
		timer.start()

func set_done():
	if timer:
		timer.stop()
	set_process(false)
	visible = false
	propagate_call("set_visible", [false])
	done.emit()
	
