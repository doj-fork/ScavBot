extends CanvasLayer

@onready var health = $Health
@onready var gun = $GunType
@onready var ammo = $Ammo

func _process(_delta):
	if Global.hudActive == false or Global.craftActive == true:
		visible = false
	else:
		visible = true

	health.text = " Energy: " + str(Stats.health)
	gun.text = " " + Gun.type
	ammo.text = " " + str(Gun.ammo)
	
	print(Gun.ammo)
