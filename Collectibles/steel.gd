extends CollectibleBase

func _setup() -> void:
	await get_tree().create_timer(0.01, false).timeout
	sprite.texture = load("res://Assets/NatureAssets/RefinedScrap" + str(randi_range(1, 3)) + ".png")
	
func _giveResources() -> String:
	var burn: int = randi_range(1, 4)
	if burn != 4:
		Inventory.steel += 1
		return "+1 Steel"
	else:
		Inventory.scrap += 1
		return "+1 Scrap"
