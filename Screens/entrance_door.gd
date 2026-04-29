extends Node2D

var entered = false


func _process(_delta):
	if Input.is_action_just_pressed("Interact") and entered == true and visible == true:
		get_tree().change_scene_to_file.call_deferred("res://Screens/game_loader.tscn")

func areaEntered(_area: Area2D) -> void:
	entered = true

func areaExited(_area: Area2D) -> void:
	entered = false
