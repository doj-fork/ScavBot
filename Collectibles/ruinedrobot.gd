extends Sprite2D

func _ready():
	texture = load("res://Assets/NatureAssets/Robot" + str(randi_range(1, 3)) + ".png")
