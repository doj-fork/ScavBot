extends Node

var type = "Null"
var special = "Null"
var ammo = 0
var precision = 0
var damage = 0
var speed = 0

func craft(handle, chamber, barrel, muzzle):
	print(handle)
	print(chamber)
	print(barrel)
	print(muzzle)
	var burnType = "Null"
	var burnSpecial = "Null"
	var burnAmmo = 0
	var burnAmmoMult = 0
	var burnPrecision = 0
	
	if handle in ["Wood"]:
		burnAmmoMult = 1.0
	elif handle in ["Rock"]:
		burnAmmoMult = 1.25
	elif handle in ["Scrap", "Battery"]:
		print("RUN")
		burnAmmoMult = 1.5
	elif handle in ["Steel", "Circuit"]:
		burnAmmoMult = 1.75
		
	if chamber in ["Wood", "Rock"]:
		burnType = "Handgun"
		burnAmmo = 12
		burnPrecision = 5
		damage = 35
		speed = 1000
	elif chamber in ["Scrap"]:
		burnType = "Shotgun"
		burnAmmo = 8
		burnPrecision = 15
		damage = 20
		speed = 1150
	elif chamber in ["Steel"]:
		burnType = "Sniper"
		burnAmmo = 6
		burnPrecision = 2
		damage = 80
		speed = 2000
	elif chamber in ["Battery", "Circuit"]:
		burnType = "AR"
		burnAmmo = 90
		burnPrecision = 10
		damage = 4
		speed = 1650
		
	if barrel in ["Wood", "Rock"]:
		burnPrecision += 4
	elif barrel in ["Scrap"]:
		burnPrecision += 2
	elif barrel in ["Steel", "Circuit", "Battery"]:
		burnPrecision -= 1
		
	if muzzle in ["Wood", "Rock"]:
		pass
	elif barrel in ["Scrap", "Steel"]:
		damage *= 1.33
		damage = int(ceil(damage))
	elif barrel in ["Circuit", "Battery"]:
		burnSpecial = "Electricity"
		
	type = burnType
	ammo = int(ceil(burnAmmo * burnAmmoMult))
	precision = burnPrecision
	special = burnSpecial

func _process(_delta):
	if ammo <= 0:
		type = "Null"
		special = "Null"
		ammo = 0
		precision = 0
		damage = 0
		speed = 0
