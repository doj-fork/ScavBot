extends CollectibleBase

func _setup() -> void:
	await get_tree().create_timer(0.01, false).timeout
	sprite.texture = load("res://Assets/NatureAssets/Computer" + str(randi_range(1, 2)) + ".png")

func _giveResources() -> String:
	var burn: int = randi_range(1, 3)
	if burn == 1 or burn == 2:
		Inventory.battery += 1
		return "+1 Battery"
	else:
		Inventory.circuit += 1
		return "+1 Circuit"
