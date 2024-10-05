extends Node2D


func _ready():
	for device in Input.get_connected_joypads():
		print("device: ", device)
	
func _process(delta):
	pass
	
func _unhandled_input(event):
	print("input ", event)
	print(event.device)
