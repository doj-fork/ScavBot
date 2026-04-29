extends Node2D


func pressPlay() -> void:
	Transition.playTransition()
	await get_tree().create_timer(0.6, false).timeout
	get_tree().change_scene_to_file("res://Screens/game_loader.tscn")
	Global.hudActive = true
