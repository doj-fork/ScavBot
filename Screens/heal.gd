extends Node2D

var entered = false

func _ready():
	visible = true
	
func _process(_delta):
	if Input.is_action_just_pressed("Interact") and entered == true and visible == true:
		visible = false
		Stats.health += 50
		if Stats.health > 100:
			Stats.health = 100

func areaEntered(_area: Area2D) -> void:
	entered = true

func areaExited(_area: Area2D) -> void:
	entered = false
