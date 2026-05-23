extends CollectibleBase

func _setup() -> void:
	await get_tree().create_timer(0.01, false).timeout
	sprite.texture = load("res://Assets/NatureAssets/ScrapPile" + str(randi_range(1, 3)) + ".png")

func _giveResources() -> String:
	var burn: int = randi_range(1, 5)
	if burn != 5:
		Inventory.scrap += 1
		return "+1 Scrap"
	else:
		Inventory.steel += 1
		return "+1 Steel"
