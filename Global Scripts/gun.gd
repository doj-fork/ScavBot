extends Node

var type = "Null"
var ammo = 0
var precision = 0
var damage = 0
var speed = 0

func craft(handle, chamber, barrel, muzzle):
	var burnType = "Null"
	var burnAmmo = 0
	var burnAmmoMult = 0
	var burnPrecision = 0
	var flavorText = ""
	
	if handle in ["Wood"]:
		burnAmmoMult = 1.0
		flavorText = flavorText + "W"
	elif handle in ["Rock"]:
		burnAmmoMult = 1.25
		flavorText = flavorText + "R1"
	elif handle in ["Scrap", "Battery"]:
		burnAmmoMult = 1.5
		flavorText = flavorText + "RS"
	elif handle in ["Steel", "Circuit"]:
		burnAmmoMult = 1.75
		flavorText = flavorText + "SX"
		
	if chamber in ["Wood", "Rock"]:
		burnType = "Handgun"
		burnAmmo = 12
		burnPrecision = 5
		damage = 35
		speed = 1000
	elif chamber in ["Scrap"]:
		burnType = "Shotgun"
		burnAmmo = 10
		burnPrecision = 15
		damage = 16
		speed = 1150
	elif chamber in ["Steel"]:
		burnType = "Sniper"
		burnAmmo = 13
		burnPrecision = 2
		damage = 85
		speed = 2500
	elif chamber in ["Battery", "Circuit"]:
		burnType = "AR"
		burnAmmo = 90
		burnPrecision = 15
		damage = 8
		speed = 1650
		
	if barrel in ["Wood", "Rock"]:
		burnPrecision += 4
		flavorText = flavorText + "W"
	elif barrel in ["Scrap"]:
		burnPrecision += 2
		flavorText = flavorText + "M3"
	elif barrel in ["Steel", "Circuit", "Battery"]:
		burnPrecision -= 1
		flavorText = flavorText + "VX"
		
	if muzzle in ["Wood", "Rock"]:
		flavorText = flavorText + "-2"
	elif muzzle in ["Scrap", "Steel"]:
		damage *= 1.33
		damage = int(ceil(damage))
		flavorText = flavorText + "-ML"
	elif muzzle in ["Circuit", "Battery"]:
		damage *= 1.67
		damage = int(ceil(damage))
		flavorText = flavorText + "-LTD"
		
	if chamber in ["Wood", "Rock"]:
		flavorText = flavorText + " Pistol"
	elif chamber in ["Scrap"]:
		flavorText = flavorText + " Shotgun"
	elif chamber in ["Steel"]:
		flavorText = flavorText + " Sniper Rifle"
	elif chamber in ["Battery", "Circuit"]:
		flavorText = flavorText + " Automatic"
		
	damage += ceil(3 * Stats.damageMult)
	type = burnType
	ammo = int(ceil(burnAmmo * burnAmmoMult))
	precision = burnPrecision
	
	Global.bulletMax = ammo
	
	Hud.gunCraft(flavorText)

func _process(_delta):
	if ammo <= 0:
		type = "Null"
