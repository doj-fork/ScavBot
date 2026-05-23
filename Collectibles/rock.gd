extends CollectibleBase

func _setup() -> void:
	await get_tree().create_timer(0.01, false).timeout
	sprite.texture = load("res://Assets/NatureAssets/Rock" + str(randi_range(1, 3)) + ".png")

func _giveResources() -> String:
	Inventory.rock += 1
	return "+1 Rock"
