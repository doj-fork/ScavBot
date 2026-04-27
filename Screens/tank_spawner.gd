extends Node2D

@onready var tank = preload("res://Enemies/Tank/tank.tscn")

func _ready():
	spawnTank()
	
func spawnTank():
	await get_tree().create_timer(17, false).timeout
	var newTank = tank.instantiate()
	self.call_deferred("add_child", newTank)
	spawnTank()
