extends CanvasLayer

@onready var craftButton = $CraftButton
@onready var hoverSprite = $Hover

@onready var handleItemSprite = $Blueprint/HandleItem
@onready var chamberItemSprite = $Blueprint/ChamberItem
@onready var barrelItemSprite = $Blueprint/BarrelItem
@onready var muzzleItemSprite = $Blueprint/MuzzleItem

@onready var woodNum = $Inventory/WoodNum
@onready var rockNum = $Inventory/RockNum
@onready var scrapNum = $Inventory/ScrapNum
@onready var steelNum = $Inventory/SteelNum
@onready var circuitNum = $Inventory/CircuitNum
@onready var batteryNum = $Inventory/BatteryNum

#Handle, Chamber, Barrel, Muzzle
var activeCraftList = ["Null", "Null", "Null", "Null"]
var activeItem = "Null"

func _ready():
	visible = false
	craftButton.visible = false
	handleItemSprite.visible = false
	chamberItemSprite.visible = false
	barrelItemSprite.visible = false
	muzzleItemSprite.visible = false
	
func _process(_delta):
	if Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == false:
		reset("N")
		visible = true
		Global.craftActive = true
		get_tree().paused = true
	elif Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == true:
		visible = false
		Global.craftActive = false
		get_tree().paused = false
		
	buttonCheck()
	hoverCheck()
	slotCheck()
	numCheck()

func reset(arg):
	if arg == "N":
		recount()
		for item in activeCraftList:
			if item == "Wood":
				Inventory.wood += 1
			elif item == "Rock":
				Inventory.rock += 1
			elif item == "Scrap":
				Inventory.scrap += 1
			elif item == "Steel":
				Inventory.steel += 1
			elif item == "Circuit":
				Inventory.circuit += 1
			elif item == "Battery":
				Inventory.battery += 1
			else:
				pass
	activeCraftList = ["Null", "Null", "Null", "Null"]
	activeItem = "Null"
		
	
	
func buttonCheck():
	if "Null" in activeCraftList:
		craftButton.visible = false
	else:
		craftButton.visible = true
	
func hoverCheck():
	hoverSprite.global_position = hoverSprite.get_global_mouse_position()
	if activeItem == "Null":
		hoverSprite.visible = false
	else:
		hoverSprite.visible = true
		if activeItem == "Wood":
			hoverSprite.frame = 0
		elif activeItem == "Rock":
			hoverSprite.frame = 1
		elif activeItem == "Scrap":
			hoverSprite.frame = 2
		elif activeItem == "Steel":
			hoverSprite.frame = 3
		elif activeItem == "Circuit":
			hoverSprite.frame = 4
		elif activeItem == "Battery":
			hoverSprite.frame = 5

func slotCheck():
	if activeCraftList[0] == "Null":
		handleItemSprite.visible = false
	elif activeCraftList[0] != "Null":
		handleItemSprite.visible = true
		handleItemSprite.texture = load("res://Assets/Crafting Module/" + activeCraftList[0] + ".png")

	if activeCraftList[1] == "Null":
		chamberItemSprite.visible = false
	elif activeCraftList[1] != "Null":
		chamberItemSprite.visible = true
		chamberItemSprite.texture = load("res://Assets/Crafting Module/" + activeCraftList[1] + ".png")

	if activeCraftList[2] == "Null":
		barrelItemSprite.visible = false
	elif activeCraftList[2] != "Null":
		barrelItemSprite.visible = true
		barrelItemSprite.texture = load("res://Assets/Crafting Module/" + activeCraftList[2] + ".png")

	if activeCraftList[3] == "Null":
		muzzleItemSprite.visible = false
	elif activeCraftList[3] != "Null":
		muzzleItemSprite.visible = true
		muzzleItemSprite.texture = load("res://Assets/Crafting Module/" + activeCraftList[3] + ".png")

func numCheck():
	woodNum.text = " " + str(Inventory.wood)
	rockNum.text = " " + str(Inventory.rock)
	scrapNum.text = " " + str(Inventory.scrap)
	steelNum.text = " " + str(Inventory.steel)
	circuitNum.text = " " + str(Inventory.circuit)
	batteryNum.text = " " + str(Inventory.battery)

func recount():
	if activeItem == "Wood":
		Inventory.wood += 1
	elif activeItem == "Rock":
		Inventory.rock += 1
	elif activeItem == "Scrap":
		Inventory.scrap += 1
	elif activeItem == "Steel":
		Inventory.steel += 1
	elif activeItem == "Circuit":
		Inventory.circuit += 1
	elif activeItem == "Battery":
		Inventory.battery += 1



func setHandle() -> void:
	if activeItem != "Null" and activeCraftList[0] == "Null":
		activeCraftList[0] = activeItem
		activeItem = "Null"
	elif activeItem != "Null" and activeCraftList[0] != "Null":
		var burn = activeCraftList[0]
		activeCraftList[0] = activeItem
		activeItem = burn
	elif activeItem == "Null" and activeCraftList[0] != "Null":
		activeItem = activeCraftList[0]
		activeCraftList[0] = "Null"

func setChamber() -> void:
	if activeItem != "Null" and activeCraftList[1] == "Null":
		activeCraftList[1] = activeItem
		activeItem = "Null"
	elif activeItem != "Null" and activeCraftList[1] != "Null":
		var burn = activeCraftList[1]
		activeCraftList[1] = activeItem
		activeItem = burn
	elif activeItem == "Null" and activeCraftList[1] != "Null":
		activeItem = activeCraftList[1]
		activeCraftList[1] = "Null"

func setBarrel() -> void:
	if activeItem != "Null" and activeCraftList[2] == "Null":
		activeCraftList[2] = activeItem
		activeItem = "Null"
	elif activeItem != "Null" and activeCraftList[2] != "Null":
		var burn = activeCraftList[2]
		activeCraftList[2] = activeItem
		activeItem = burn
	elif activeItem == "Null" and activeCraftList[2] != "Null":
		activeItem = activeCraftList[2]
		activeCraftList[2] = "Null"

func setMuzzle() -> void:
	if activeItem != "Null" and activeCraftList[3] == "Null":
		activeCraftList[3] = activeItem
		activeItem = "Null"
	elif activeItem != "Null" and activeCraftList[3] != "Null":
		var burn = activeCraftList[3]
		activeCraftList[3] = activeItem
		activeItem = burn
	elif activeItem == "Null" and activeCraftList[3] != "Null":
		activeItem = activeCraftList[3]
		activeCraftList[3] = "Null"



func pickBattery() -> void:
	if activeItem == "Battery":
		recount()
		activeItem = "Null"
	elif activeItem != "Battery" and Inventory.battery > 0:
		recount()
		activeItem = "Battery"
		Inventory.battery -= 1

func pickWood() -> void:
	if activeItem == "Wood":
		recount()
		activeItem = "Null"
	elif activeItem != "Wood" and Inventory.wood > 0:
		recount()
		activeItem = "Wood"
		Inventory.wood -= 1

func pickRock() -> void:
	if activeItem == "Rock":
		recount()
		activeItem = "Null"
	elif activeItem != "Rock" and Inventory.rock > 0:
		recount()
		activeItem = "Rock"
		Inventory.rock -= 1

func pickCircuit() -> void:
	if activeItem == "Circuit":
		recount()
		activeItem = "Null"
	elif activeItem != "Circuit" and Inventory.circuit > 0:
		recount()
		activeItem = "Circuit"
		Inventory.circuit -= 1

func pickSteel() -> void:
	if activeItem == "Steel":
		recount()
		activeItem = "Null"
	elif activeItem != "Steel" and Inventory.steel > 0:
		recount()
		activeItem = "Steel"
		Inventory.steel -= 1

func pickScrap() -> void:
	if activeItem == "Scrap":
		recount()
		activeItem = "Null"
	elif activeItem != "Scrap" and Inventory.scrap > 0:
		recount()
		activeItem = "Scrap"
		Inventory.scrap -= 1
		

func craftGun() -> void:
	if "Null" not in activeCraftList:
		reset("Y")
		visible = false
		Global.craftActive = false
		get_tree().paused = false
