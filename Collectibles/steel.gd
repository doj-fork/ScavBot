extends CollectibleBase

func _giveResources() -> void:
	var burn: int = randi_range(1, 3)
	if burn == 1 or burn == 2:
		Inventory.steel += 1
	elif burn == 3:
		Inventory.scrap += 2
