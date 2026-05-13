extends CollectibleBase

func _setup() -> void:
	sprite.texture = load("res://Assets/NatureAssets/Tree" + str(randi_range(1, 3)) + ".png")

func _giveResources() -> void:
	Inventory.wood += 2
