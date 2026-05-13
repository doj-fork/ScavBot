extends Node2D

@onready var ranger = preload("res://Enemies/Ranger/ranger.tscn")
@onready var rangerbullet = preload("res://Enemies/Ranger/ranger_bullet.tscn")

func _ready():
	spawnRanger()
	
func spawnRanger():
	await get_tree().create_timer(randi_range(3, 8), false).timeout
	var newRanger = ranger.instantiate()
	self.call_deferred("add_child", newRanger)
	spawnRanger()
