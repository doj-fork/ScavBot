extends CollectibleBase

func _setup() -> void:
	sprite.texture = load("res://Assets/NatureAssets/ScrapPile" + str(randi_range(1, 3)) + ".png")

func _giveResources() -> void:
	var burn: int = randi_range(1, 3)
	if burn == 1 or burn == 2:
		Inventory.scrap += 2
	elif burn == 3:
		Inventory.steel += 1
