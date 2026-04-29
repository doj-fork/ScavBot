extends CharacterBody2D

@onready var animTree = $AnimationTree
@onready var stateMachine = animTree.get("parameters/playback")

var immunity = false

var inputDir = Vector2(0, 0)
var animDir = Vector2(0, 0)

func _process(_delta):
	Global.playerPos = global_position
	inputDir = (Vector2(Input.get_action_strength("Right") - Input.get_action_strength("Left"), Input.get_action_strength("Down") - Input.get_action_strength("Up"))).normalized()
	velocity = inputDir * Stats.speed
	if inputDir != Vector2(0, 0):
		animDir = inputDir
	animUpdate()
	if Global.canMove == 0:
		move_and_slide()
	
	if Stats.health < 1:
		get_tree().change_scene_to_file.call_deferred("res://Screens/death.tscn")

func animUpdate():
	animTree.set("parameters/Idle/blend_position", animDir)
	animTree.set("parameters/Walk/blend_position", animDir)
	
	if velocity != Vector2(0, 0):
		stateMachine.travel("Walk")
	elif velocity == Vector2(0, 0):
		stateMachine.travel("Idle")


func _on_area_2d_area_entered(_area: Area2D) -> void:
	if immunity == false:
		immunity = true
		Stats.health -= 10
		await get_tree().create_timer(0.75, false).timeout
		immunity = false
