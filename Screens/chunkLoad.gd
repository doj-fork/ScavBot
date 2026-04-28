extends Node2D

var c_01 = preload("res://Chunks/c_01.tscn")

func _ready():
	generate()
	
func generate():
	#await Signals.chunkGen
	await get_tree().create_timer(1, false).timeout
	var newChunk = c_01.instantiate()
	self.call_deferred("add_child", newChunk)
	generate()
	
