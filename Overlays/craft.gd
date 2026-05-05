extends CanvasLayer

@onready var woodNum = $Text/WoodNum
@onready var rockNum = $Text/RockNum
@onready var scrapNum = $Text/ScrapNum
@onready var steelNum = $Text/SteelNum
@onready var circuitNum = $Text/CircuitNum
@onready var batteryNum = $Text/BatteryNum

@onready var hItem = $Blueprint/HandleItem
@onready var hShadow = $Blueprint/HandleItem/Shadow
@onready var cItem = $Blueprint/ChamberItem
@onready var cShadow = $Blueprint/ChamberItem/Shadow
@onready var bItem = $Blueprint/BarrelItem
@onready var bShadow = $Blueprint/BarrelItem/Shadow
@onready var mItem = $Blueprint/MuzzleItem
@onready var mShadow = $Blueprint/MuzzleItem/Shadow

@onready var craftButton = $Buttons/Craft
@onready var hoverItem = $HoverItem

var canCraft = false

var woodActive = false
var rockActive = false
var scrapActive = false
var steelActive = false
var circuitActive = false
var batteryActive = false

var mousePressed = false
var hHover = false
var cHover = false
var bHover = false
var mHover = false

#Handle, Chamber, Barrel, Muzzle
var activeCraftList = ["Null", "Null", "Null", "Null"]
var activeItem = "Null"

func _ready():
	visible = false
	hItem.visible = false
	cItem.visible = false
	bItem.visible = false
	mItem.visible = false
	craftButton.visible = false
	hoverItem.visible = false
	
func _process(_delta):
	if Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == false:
		visible = true
		Global.craftActive = true
		get_tree().paused = true
	elif Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == true:
		visible = false
		Global.craftActive = false
		get_tree().paused = false
		refund(4)
	
	if "Null" not in activeCraftList:
		craftButton.visible = true
		canCraft = true
	else:
		craftButton.visible = false
		canCraft = false
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mousePressed = true
	else:
		mousePressed = false
	updateText()
	updateIcons()
	updateHover()

func updateText(): 
	woodNum.text = str(Inventory.wood)
	rockNum.text = str(Inventory.rock)
	scrapNum.text = str(Inventory.scrap)
	steelNum.text = str(Inventory.steel)
	circuitNum.text = str(Inventory.circuit)
	batteryNum.text = str(Inventory.battery)
func craftGun() -> void:
	if "Null" not in activeCraftList:
		Gun.craft(activeCraftList[0], activeCraftList[1], activeCraftList[2], activeCraftList[3])
		refund(5)

func updateIcons():
	if activeCraftList[0] == "Null":
		hItem.visible = false
	else:
		hItem.visible = true
		if activeCraftList[0] == "Wood":
			hItem.frame = 0
			hShadow.frame = 0
		elif activeCraftList[0] == "Rock":
			hItem.frame = 1
			hShadow.frame = 1
		elif activeCraftList[0] == "Scrap":
			hItem.frame = 2
			hShadow.frame = 2
		elif activeCraftList[0] == "Steel":
			hItem.frame = 3
			hShadow.frame = 3
		elif activeCraftList[0] == "Circuit":
			hItem.frame = 4
			hShadow.frame = 4
		elif activeCraftList[0] == "Battery":
			hItem.frame = 5
			hShadow.frame = 5
		
	if activeCraftList[1] == "Null":
		cItem.visible = false
	else:
		cItem.visible = true
		if activeCraftList[1] == "Wood":
			cItem.frame = 0
			cShadow.frame = 0
		elif activeCraftList[1] == "Rock":
			cItem.frame = 1
			cShadow.frame = 1
		elif activeCraftList[1] == "Scrap":
			cItem.frame = 2
			cShadow.frame = 2
		elif activeCraftList[1] == "Steel":
			cItem.frame = 3
			cShadow.frame = 3
		elif activeCraftList[1] == "Circuit":
			cItem.frame = 4
			cShadow.frame = 4
		elif activeCraftList[1] == "Battery":
			cItem.frame = 5
			cShadow.frame = 5
			
	if activeCraftList[2] == "Null":
		bItem.visible = false
	else:
		bItem.visible = true
		if activeCraftList[2] == "Wood":
			bItem.frame = 0
			bShadow.frame = 0
		elif activeCraftList[2] == "Rock":
			bItem.frame = 1
			bShadow.frame = 1
		elif activeCraftList[2] == "Scrap":
			bItem.frame = 2
			bShadow.frame = 2
		elif activeCraftList[2] == "Steel":
			bItem.frame = 3
			bShadow.frame = 3
		elif activeCraftList[2] == "Circuit":
			bItem.frame = 4
			bShadow.frame = 4
		elif activeCraftList[2] == "Battery":
			bItem.frame = 5
			bShadow.frame = 5
			
	if activeCraftList[3] == "Null":
		mItem.visible = false
	else:
		mItem.visible = true
		if activeCraftList[3] == "Wood":
			mItem.frame = 0
			mShadow.frame = 0
		elif activeCraftList[3] == "Rock":
			mItem.frame = 1
			mShadow.frame = 1
		elif activeCraftList[3] == "Scrap":
			mItem.frame = 2
			mShadow.frame = 2
		elif activeCraftList[3] == "Steel":
			mItem.frame = 3
			mShadow.frame = 3
		elif activeCraftList[3] == "Circuit":
			mItem.frame = 4
			mShadow.frame = 4
		elif activeCraftList[3] == "Battery":
			mItem.frame = 5
			mShadow.frame = 5
func updateHover():
	if activeItem == "Null":
		hoverItem.visible = false
	else:
		hoverItem.visible = true
		if activeItem == "Wood":
			hoverItem.frame = 0
		elif activeItem == "Rock":
			hoverItem.frame = 1
		elif activeItem == "Scrap":
			hoverItem.frame = 2
		elif activeItem == "Steel":
			hoverItem.frame = 3
		elif activeItem == "Circuit":
			hoverItem.frame = 4
		elif activeItem == "Battery":
			hoverItem.frame = 5

func hEnter() -> void:
	hHover = true
func hExit() -> void:
	hHover = false
func cEnter() -> void:
	cHover = true
func cExit() -> void:
	cHover = false
func bEnter() -> void:
	bHover = true
func bExit() -> void:
	bHover = false
func mEnter() -> void:
	mHover = true
func mExit() -> void:
	mHover = false

func woodPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.wood > 0:
		activeItem = "Wood"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Wood")
		activeItem = "Null"
func rockPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.rock > 0:
		activeItem = "Rock"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Rock")
		activeItem = "Null"
func scrapPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.scrap > 0:
		activeItem = "Scrap"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Scrap")
		activeItem = "Null"
func steelPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.steel > 0:
		activeItem = "Steel"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Steel")
		activeItem = "Null"
func circuitPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.circuit > 0:
		activeItem = "Circuit"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Circuit")
		activeItem = "Null"
func batteryPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.battery > 0:
		activeItem = "Battery"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Battery")
		activeItem = "Null"

func enterCheck(arg):
	if hHover == true:
		if activeCraftList[0] != "Null":
			refund(0)
		activeCraftList[0] = arg
		transact(arg)
	elif cHover == true:
		if activeCraftList[1] != "Null":
			refund(1)
		activeCraftList[1] = arg
		transact(arg)
	elif bHover == true:
		if activeCraftList[2] != "Null":
			refund(2)
		activeCraftList[2] = arg
		transact(arg)
	elif mHover == true:
		if activeCraftList[3] != "Null":
			refund(3)
		activeCraftList[3] = arg
		transact(arg)
func refund(arg):
	if arg not in [4, 5]:
		if activeCraftList[arg] == "Wood":
			Inventory.wood += 1
		elif activeCraftList[arg] == "Rock":
			Inventory.rock += 1
		elif activeCraftList[arg] == "Scrap":
			Inventory.scrap += 1
		elif activeCraftList[arg] == "Steel":
			Inventory.steel += 1
		elif activeCraftList[arg] == "Circuit":
			Inventory.circuit += 1
		elif activeCraftList[arg] == "Battery":
			Inventory.battery += 1
	elif arg == 4:
		activeItem = "Null"
		for i in range(4):
			if activeCraftList[i - 1] == "Wood":
				Inventory.wood += 1
			elif activeCraftList[i - 1] == "Rock":
				Inventory.rock += 1
			elif activeCraftList[i - 1] == "Scrap":
				Inventory.scrap += 1
			elif activeCraftList[i - 1] == "Steel":
				Inventory.steel += 1
			elif activeCraftList[i - 1] == "Circuit":
				Inventory.circuit += 1
			elif activeCraftList[i - 1] == "Battery":
				Inventory.battery += 1
		activeCraftList = ["Null", "Null", "Null", "Null"]
	elif arg == 5:
		activeItem = "Null"
		activeCraftList = ["Null", "Null", "Null", "Null"]
		visible = false
		Global.craftActive = false
		get_tree().paused = false
func transact(arg):
	if arg == "Wood":
		Inventory.wood -= 1
	elif arg == "Rock":
		Inventory.rock -= 1
	elif arg == "Scrap":
		Inventory.scrap -= 1
	elif arg == "Steel":
		Inventory.steel -= 1
	elif arg == "Circuit":
		Inventory.circuit -= 1
	elif arg == "Battery":
		Inventory.battery -= 1
