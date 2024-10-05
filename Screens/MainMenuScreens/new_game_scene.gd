extends Node2D


func _on_ok_button_pressed():
	pass # Replace with function body.


func _on_cancel_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
