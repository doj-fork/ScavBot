extends Node2D

func _ready():
	for child in self.get_children():
		child.reparent(get_tree().current_scene)
