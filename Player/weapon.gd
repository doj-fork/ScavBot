extends Node2D

@onready var sprite = $Sprite
@onready var bullet = preload("res://Player/bullet.tscn")

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
		shoot()
	await get_tree().create_timer(0.0857, false).timeout
	runAR()
		
func runShotgun():
	if Input.is_action_just_pressed("Shoot") and Gun.ammo >= 1:
		for i in range(5):
			shoot()
			await get_tree().create_timer(0.01, false).timeout
		Gun.ammo -= 1

func runSniper():
	if Input.is_action_just_pressed("Shoot") and Gun.ammo >= 1:
		Gun.ammo -= 1
		shoot()
		
func runHandgun():
	if Input.is_action_just_pressed("Shoot") and Gun.ammo >= 1:
		Gun.ammo -= 1
		shoot()
		
func shoot():
	var newBullet = bullet.instantiate()
	self.call_deferred("add_child", newBullet)
