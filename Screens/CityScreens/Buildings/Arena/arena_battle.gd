extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered_exit(body: Node2D) -> void:
	print ("body entered ", body)
	var car_body:PlayerCar2D = body as PlayerCar2D
	if car_body:
		print("car entered exit")
		get_tree().change_scene_to_file("res://Screens/CityScreens/Buildings/Arena/BattleCompleteScene.tscn")
