extends Node2D

var entered = false

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("Interact") and entered == true and visible == true:
		Upgrades.visible = true
		Global.hudActive = false
		visible = false

func areaEntered(_area: Area2D) -> void:
	entered = true

func areaExited(_area: Area2D) -> void:
	entered = false
