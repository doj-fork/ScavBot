extends Node2D

var c_01 = preload("res://Chunks/c_01.tscn")
var c_02 = preload("res://Chunks/c_02.tscn")
var c_03 = preload("res://Chunks/c_03.tscn")
var c_04 = preload("res://Chunks/c_04.tscn")
var c_05 = preload("res://Chunks/c_05.tscn")
var c_06 = preload("res://Chunks/c_06.tscn")
var c_07 = preload("res://Chunks/c_07.tscn")
var c_08 = preload("res://Chunks/c_08.tscn")
var c_09 = preload("res://Chunks/c_09.tscn")
var c_10 = preload("res://Chunks/c_10.tscn")
var c_11 = preload("res://Chunks/c_11.tscn")

func _ready():
	generate()

func generate():
	if randi_range(1, 5) == 5:
		genEmpty()
	else:
		var roll = randi_range(1, 80)
		var rarityLim = 6 * Stats.wave
		if rarityLim >= 48:
			rarityLim = 48
			
		if roll <= (64 - rarityLim):
			genCommon()
		elif roll <= (76 - (round(rarityLim * 0.66))):
			genRare()
		else:
			genLegendary()

func genEmpty():
	print("A")
	#empty includes empty
	var newChunk = c_10.instantiate()
	self.call_deferred("add_child", newChunk)
	
func genCommon():
	print("B")
	#common includes grove, quarry, field
	var roll = randi_range(1, 5)
	match roll:
		1, 2:
			var newChunk = c_01.instantiate()
			self.call_deferred("add_child", newChunk)
		3, 4:
			var newChunk = c_02.instantiate()
			self.call_deferred("add_child", newChunk)
		5:
			var newChunk = c_11.instantiate()
			self.call_deferred("add_child", newChunk)
			
		
func genRare():
	print("C")
	#common includes junkyard, mech field, bunker, artillery
	var roll = randi_range(1, 5)
	match roll:
		1:
			var newChunk = c_03.instantiate()
			self.call_deferred("add_child", newChunk)
		2:
			var newChunk = c_04.instantiate()
			self.call_deferred("add_child", newChunk)
		3:
			var newChunk = c_06.instantiate()
			self.call_deferred("add_child", newChunk)
		4, 5:
			var newChunk = c_08.instantiate()
			self.call_deferred("add_child", newChunk)

func genLegendary():
	print("D")
	#legendary includes town, facility, front lines
	var roll = randi_range(1, 5)
	match roll:
		1, 2:
			var newChunk = c_09.instantiate()
			self.call_deferred("add_child", newChunk)
		3, 4:
			var newChunk = c_05.instantiate()
			self.call_deferred("add_child", newChunk)
		5:
			var newChunk = c_07.instantiate()
			self.call_deferred("add_child", newChunk)
