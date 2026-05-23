extends Node2D

@onready var melee = preload("res://Enemies/Melee/melee.tscn")
@onready var tank = preload("res://Enemies/Tank/tank.tscn")
@onready var ranger = preload("res://Enemies/Ranger/ranger.tscn")

var entered = false

func _ready():
	spawnEnemy()
	
func spawnEnemy():
	var waitLimit = Stats.wave - 1
	if waitLimit >= 7:
		waitLimit = 7
	await get_tree().create_timer((randi_range(14, 18) - waitLimit), false).timeout
	
	while entered == true or Global.currentEnemies >= Global.maxEnemies:
		await get_tree().create_timer(3, false).timeout

	var roll = randi_range(1, 80)
	var rarityLim = 6 * Stats.wave
	if rarityLim >= 42:
		rarityLim = 42
	
	if roll <= (60 - rarityLim):
		var newMelee = melee.instantiate()
		self.call_deferred("add_child", newMelee)
	elif roll <= (70 - (round(rarityLim * 0.66))):
		var newRanger = ranger.instantiate()
		self.call_deferred("add_child", newRanger)
	else:
		var newTank = tank.instantiate()
		self.call_deferred("add_child", newTank)
	spawnEnemy()

func _on_player_scan_area_entered(_area: Area2D) -> void:
	entered = true

func _on_player_scan_area_exited(_area: Area2D) -> void:
	entered = false
