extends CollectibleBase

func _giveResources() -> String:
	var burn: int = randi_range(1, 3)
	if burn == 1 or burn == 2:
		Inventory.steel += 1
		return "+1 Steel"
	else:
		Inventory.scrap += 2
		return "+2 Scrap"
