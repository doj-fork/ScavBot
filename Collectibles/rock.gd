extends Node2D

@onready var sprite = $Sprite
var health = 1
var cooldown = false
var entered = false

func _ready():
	sprite.texture = load("res://Assets/NatureAssets/Rock" + str(randi_range(1, 3)) + ".png")
	
func _process(_delta):
	if Input.is_action_just_pressed("Interact") and cooldown == false and entered == true:
		Global.cannotCraftCollecting = true
		cooldown = true
		Global.canMove += 1
		await get_tree().create_timer(1, false).timeout
		cooldown = false
		Global.cannotCraftCollecting = false
		Global.canMove -= 1
		health -= 1
		Inventory.rock += 2
		if health == 0:
			queue_free()

func areaEntered(_area: Area2D) -> void:
	entered = true

func areaExited(_area: Area2D) -> void:
	entered = false
