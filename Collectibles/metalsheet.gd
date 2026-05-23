extends Sprite2D

func _ready():
	texture = load("res://Assets/NatureAssets/MetalSheet" + str(randi_range(1, 4)) + ".png")
