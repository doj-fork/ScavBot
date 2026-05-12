extends Node

var health = 100
var speed = 200

var damageMult = 0
var speedMult = 0
var healthMult = 0

func majorReset():
	health = 100
	speed = 200
	damageMult = 0
	speedMult = 0
	healthMult = 0
	Inventory.wood = 0
	Inventory.rock = 0
	Inventory.scrap = 0
	Inventory.steel = 0
	Inventory.circuit = 0
	Inventory.battery = 0
