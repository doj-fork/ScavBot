extends Node2D

var entered = false
func _ready():
	Global.cannotShootIntermission = true
	BGM.play_intermission_bgm()

func _process(_delta):
	if Input.is_action_just_pressed("Interact") and entered == true and visible == true:
		BGM.fade_out()
		Transition.playTransition()
		await get_tree().create_timer(0.6, false).timeout
		get_tree().change_scene_to_file.call_deferred("res://Screens/game_loader.tscn")
		Global.cannotShootIntermission = false

func areaEntered(_area: Area2D) -> void:
	entered = true

func areaExited(_area: Area2D) -> void:
	entered = false
