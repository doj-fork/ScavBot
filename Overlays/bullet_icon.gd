extends Sprite2D

@onready var shadow = $BulletShadow
func _process(_delta):
	if Gun.type == "Handgun":
		texture = load("res://Assets/AmmoIcons/HandgunAmmoIcon.png")
		shadow.texture = load("res://Assets/AmmoIcons/HandgunAmmoIcon.png")
		position = Vector2(135, 485)
	elif Gun.type == "Shotgun":
		texture = load("res://Assets/AmmoIcons/ShotgunAmmoIcon.png")
		shadow.texture = load("res://Assets/AmmoIcons/ShotgunAmmoIcon.png")
		position = Vector2(135, 473)
	elif Gun.type == "Sniper":
		texture = load("res://Assets/AmmoIcons/SniperAmmoIcon.png")
		shadow.texture = load("res://Assets/AmmoIcons/SniperAmmoIcon.png")
		position = Vector2(135, 468)
	elif Gun.type == "AR":
		texture = load("res://Assets/AmmoIcons/AssaultRifleAmmoIcon.png")
		shadow.texture = load("res://Assets/AmmoIcons/AssaultRifleAmmoIcon.png")
		position = Vector2(135, 476)
