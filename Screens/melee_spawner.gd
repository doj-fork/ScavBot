extends Node2D

@onready var melee = preload("res://Enemies/Melee/melee.tscn")

func _ready():
	spawnMelee()
	
func spawnMelee():
	await get_tree().create_timer(randi_range(6, 12), false).timeout
	var newMelee = melee.instantiate()
	self.call_deferred("add_child", newMelee)
	spawnMelee()
