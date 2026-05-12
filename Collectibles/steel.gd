extends Node2D

@onready var sprite = $Sprite
var health = 1
var cooldown = false
var entered = false

func _ready():
	pass
	
func _process(_delta):
	if Input.is_action_just_pressed("Interact") and cooldown == false and entered == true:
		Global.cannotCraftCollecting = true
		Global.cannotShootIntermission = true
		cooldown = true
		Global.canMove += 1
		await get_tree().create_timer(1, false).timeout
		cooldown = false
		Global.cannotCraftCollecting = false
		Global.cannotShootIntermission = false
		Global.canMove -= 1
		health -= 1
		var burn = randi_range(1, 3)
		if burn == 1 or burn == 2:
			Inventory.steel += 1
		elif burn == 3:
			Inventory.scrap += 2
		if health == 0:
			queue_free()

func areaEntered(_area: Area2D) -> void:
	entered = true

func areaExited(_area: Area2D) -> void:
	entered = false
