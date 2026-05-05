extends Node2D

@onready var sprite = $Sprite

func _ready():
	sprite.texture = load("res://Assets/NatureAssets/Bush" + str(randi_range(1, 3)) + ".png")
