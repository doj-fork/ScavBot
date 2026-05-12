extends Node2D

var c_01 = preload("res://Chunks/c_01.tscn")
var c_02 = preload("res://Chunks/c_02.tscn")
var c_03 = preload("res://Chunks/c_03.tscn")
var c_04 = preload("res://Chunks/c_04.tscn")
var c_05 = preload("res://Chunks/c_05.tscn")
var c_06 = preload("res://Chunks/c_06.tscn")
var c_07 = preload("res://Chunks/c_07.tscn")

func _ready():
	generate()
	
func generate():
	
	var roll = randi_range(1, 10)
	if roll == 1:
		var newChunk = c_01.instantiate()
		self.call_deferred("add_child", newChunk)
	elif roll == 2:
		var newChunk = c_02.instantiate()
		self.call_deferred("add_child", newChunk)
	elif roll == 3:
		var newChunk = c_03.instantiate()
		self.call_deferred("add_child", newChunk)
	elif roll == 4:
		var newChunk = c_04.instantiate()
		self.call_deferred("add_child", newChunk)
	elif roll == 5:
		var newChunk = c_05.instantiate()
		self.call_deferred("add_child", newChunk)
	elif roll == 6:
		var newChunk = c_06.instantiate()
		self.call_deferred("add_child", newChunk)
	else:
		var newChunk = c_07.instantiate()
		self.call_deferred("add_child", newChunk)
	
