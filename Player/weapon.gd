extends Node2D

var cooldown = false

signal shootClick


@onready var bullet = preload("res://Player/bullet.tscn")
@onready var ar_sfx: AudioStreamPlayer2D = $"../arSFX"
@onready var sniper_sfx: AudioStreamPlayer2D = $"../sniperSFX"
@onready var sniperboltout_sfx: AudioStreamPlayer2D = $"../sniperboltoutSFX"
@onready var sniperboltin_sfx: AudioStreamPlayer2D = $"../sniperboltinSFX"
@onready var handgun_sfx: AudioStreamPlayer2D = $"../handgunSFX"
@onready var shotgun_sfx: AudioStreamPlayer2D = $"../shotgunSFX"
@onready var shotgunrackback_sfx: AudioStreamPlayer2D = $"../shotgunrackbackSFX"
@onready var shotgunrackforward_sfx: AudioStreamPlayer2D = $"../shotgunrackforwardSFX"

func _ready():
	runAR()
	runShotgun()
	runHandgun()
	runSniper()
	
func _process(_delta):
	if Input.is_action_just_pressed("Shoot") and Gun.ammo >= 1 and cooldown == false and true not in Global.cannotShootList:
		shootClick.emit()
		
func runAR():
	await shootClick
	if Gun.type == "AR":
		while Input.is_action_pressed("Shoot") and Gun.ammo >= 1 and cooldown == false:
			ar_sfx.play()
			shoot()
			Gun.ammo -= 1
			await get_tree().create_timer(0.0857, false).timeout
	runAR()
	
func runShotgun():
	await shootClick
	Hud.reloadGun()
	if Gun.type == "Shotgun":
		cooldown = true
		shotgun_sfx.play()
		for i in range(5):
			shoot(2)
			await get_tree().create_timer(0.01, false).timeout
		Gun.ammo -= 1
		shotgunrackback_sfx.play()
		await get_tree().create_timer(0.7, false).timeout
		shotgunrackforward_sfx.play()
		await get_tree().create_timer(0.3, false).timeout
		cooldown = false
	runShotgun()
	
func runSniper():
	await shootClick
	Hud.reloadGun()
	if Gun.type == "Sniper":
		cooldown = true
		sniper_sfx.play()
		shoot(3)
		Gun.ammo -= 1
		await get_tree().create_timer(0.8, false).timeout
		sniperboltout_sfx.play()
		await get_tree().create_timer(0.3, false).timeout
		sniperboltin_sfx.play()
		await get_tree().create_timer(0.1, false).timeout
		cooldown = false
	runSniper()

func runHandgun():
	await shootClick
	Hud.reloadGun()
	if Gun.type == "Handgun":
		cooldown = true
		handgun_sfx.play()
		shoot()
		Gun.ammo -= 1
		await get_tree().create_timer(0.25, false).timeout
		cooldown = false
	runHandgun()

func shoot(pierceCount: int = 1):
	var newBullet = bullet.instantiate()
	newBullet.pierceCount = pierceCount
	self.call_deferred("add_child", newBullet)
