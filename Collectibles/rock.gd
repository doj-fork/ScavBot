extends CollectibleBase

func _setup() -> void:
	sprite.texture = load("res://Assets/NatureAssets/Rock" + str(randi_range(1, 3)) + ".png")

func _giveResources() -> String:
	Inventory.rock += 2
	return "+2 Rock"
