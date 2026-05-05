extends Node2D

@onready var sprite = $Sprite
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
	sprite.visible = false
	runAR()

func _process(_delta):
	if Gun.type != "Null":
		sprite.visible = true
	else:
		sprite.visible = false
	if Gun.type == "Shotgun":
		runShotgun()
	elif Gun.type == "Handgun":
		runHandgun()
	elif Gun.type == "Sniper":
		runSniper()
		
func runAR():
	if Input.is_action_pressed("Shoot") and Gun.ammo >= 1:
		Gun.ammo -= 1
		ar_sfx.play()
		shoot()
	await get_tree().create_timer(0.0857, false).timeout
	runAR()
		
func runShotgun():
	if Input.is_action_just_pressed("Shoot") and Gun.ammo >= 1:
		for i in range(5):
			shoot()
			await get_tree().create_timer(0.01, false).timeout
		await get_tree().create_timer(0.45, false).timeout
		shotgunrackback_sfx.play()
		Gun.ammo -= 1
		await get_tree().create_timer(0.45, false).timeout
		shotgunrackforward_sfx.play()

func runSniper():
	if Input.is_action_just_pressed("Shoot") and Gun.ammo >= 1:
		sniper_sfx.play()
		shoot()
		await get_tree().create_timer(0.45, false).timeout
		sniperboltout_sfx.play()
		Gun.ammo -= 1
		await get_tree().create_timer(0.45, false).timeout
		sniperboltin_sfx.play()
		
func runHandgun():
	if Input.is_action_just_pressed("Shoot") and Gun.ammo >= 1:
		Gun.ammo -= 1
		handgun_sfx.play()
		shoot()
		
func shoot():
	var newBullet = bullet.instantiate()
	self.call_deferred("add_child", newBullet)
