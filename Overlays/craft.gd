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

@onready var gunNameLabel = $Text/GunName
@onready var craftButton = $Buttons/Craft
@onready var hoverItem = $HoverItem
@onready var woodSprite: Sprite2D = $Inventory/Wood
@onready var rockSprite: Sprite2D = $Inventory/Rock
@onready var scrapSprite: Sprite2D = $Inventory/Scrap
@onready var steelSprite: Sprite2D = $Inventory/Steel
@onready var circuitSprite: Sprite2D = $Inventory/Circuit
@onready var batterySprite: Sprite2D = $Inventory/Battery
@onready var dropmaterialcrafting_sfx: AudioStreamPlayer2D = $dropmaterialcraftingSFX
@onready var pickupcrafting_sfx: AudioStreamPlayer2D = $pickupcraftingSFX
@onready var hovercrafting_sfx: AudioStreamPlayer2D = $hovercraftingSFX
@onready var craftingmaterialerror_sfx: AudioStreamPlayer2D = $craftingmaterialerrorSFX
@onready var craftingconfirm_sfx: AudioStreamPlayer2D = $craftingconfirmSFX


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
var last_hover_item_for_sfx: String = "Null"
var hovered_material_name: String = ""
const MATERIAL_NORMAL_MODULATE: Color = Color(1.0, 1.0, 1.0, 1.0)
const MATERIAL_HOVER_MODULATE: Color = Color(1.08, 1.08, 1.08, 1.5)

func _ready():
	visible = false
	hItem.visible = false
	cItem.visible = false
	bItem.visible = false
	mItem.visible = false
	craftButton.visible = false
	hoverItem.visible = false
	reset_material_highlights()
	
func openCraft():
		visible = true
		Global.craftActive = true
		get_tree().paused = true
		Global.cannotPauseCrafting = true

func _process(_delta):
	if Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == false:
		visible = true
		Global.craftActive = true
		Global.cannotPauseCrafting = true
		get_tree().paused = true
	elif Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == true:
		visible = false
		Global.craftActive = false
		get_tree().paused = false
		Global.cannotPauseCrafting = false
		reset_material_highlights()
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
		
	if Input.is_action_just_pressed("Refund"):
		refundSlot()

	updateText()
	updateIcons()
	updateHover()

func refundSlot():
	if hHover == true and activeCraftList[0] != "Null":
		refundItem(activeCraftList[0])
		pickupcrafting_sfx.play()
		activeCraftList[0] = "Null"
	elif cHover == true and activeCraftList[1] != "Null":
		refundItem(activeCraftList[1])
		pickupcrafting_sfx.play()
		activeCraftList[1] = "Null"
	elif bHover == true and activeCraftList[2] != "Null":
		refundItem(activeCraftList[2])
		pickupcrafting_sfx.play()
		activeCraftList[2] = "Null"
	elif mHover == true and activeCraftList[3] != "Null":
		refundItem(activeCraftList[3])
		pickupcrafting_sfx.play()
		activeCraftList[3] = "Null"

func refundItem(arg):
	if arg == "Wood":
		Inventory.wood += 1
	elif arg == "Rock":
		Inventory.rock += 1
	elif arg == "Scrap":
		Inventory.scrap += 1
	elif arg == "Steel":
		Inventory.steel += 1
	elif arg == "Circuit":
		Inventory.circuit += 1
	elif arg == "Battery":
		Inventory.battery += 1

func reset_material_highlights() -> void:
	woodSprite.modulate = MATERIAL_NORMAL_MODULATE
	rockSprite.modulate = MATERIAL_NORMAL_MODULATE
	scrapSprite.modulate = MATERIAL_NORMAL_MODULATE
	steelSprite.modulate = MATERIAL_NORMAL_MODULATE
	circuitSprite.modulate = MATERIAL_NORMAL_MODULATE
	batterySprite.modulate = MATERIAL_NORMAL_MODULATE
	hovered_material_name = ""

func _get_material_sprite(material_name: String) -> Sprite2D:
	match material_name:
		"Wood":
			return woodSprite
		"Rock":
			return rockSprite
		"Scrap":
			return scrapSprite
		"Steel":
			return steelSprite
		"Circuit":
			return circuitSprite
		"Battery":
			return batterySprite
		_:
			return null

func _set_material_highlight(material_name: String, is_hovered: bool) -> void:
	var target_sprite: Sprite2D = _get_material_sprite(material_name)
	if target_sprite == null:
		return
	if is_hovered:
		target_sprite.modulate = MATERIAL_HOVER_MODULATE
		if hovered_material_name != material_name and visible and Global.craftActive:
			hovercrafting_sfx.play()
		hovered_material_name = material_name
	else:
		target_sprite.modulate = MATERIAL_NORMAL_MODULATE
		if hovered_material_name == material_name:
			hovered_material_name = ""

func _on_wood_pick_mouse_entered() -> void:
	_set_material_highlight("Wood", true)

func _on_wood_pick_mouse_exited() -> void:
	_set_material_highlight("Wood", false)

func _on_rock_pick_mouse_entered() -> void:
	_set_material_highlight("Rock", true)

func _on_rock_pick_mouse_exited() -> void:
	_set_material_highlight("Rock", false)

func _on_scrap_pick_mouse_entered() -> void:
	_set_material_highlight("Scrap", true)

func _on_scrap_pick_mouse_exited() -> void:
	_set_material_highlight("Scrap", false)

func _on_steel_pick_mouse_entered() -> void:
	_set_material_highlight("Steel", true)

func _on_steel_pick_mouse_exited() -> void:
	_set_material_highlight("Steel", false)

func _on_circuit_pick_mouse_entered() -> void:
	_set_material_highlight("Circuit", true)

func _on_circuit_pick_mouse_exited() -> void:
	_set_material_highlight("Circuit", false)

func _on_battery_pick_mouse_entered() -> void:
	_set_material_highlight("Battery", true)

func _on_battery_pick_mouse_exited() -> void:
	_set_material_highlight("Battery", false)

func updateText(): 
	woodNum.text = str(Inventory.wood)
	rockNum.text = str(Inventory.rock)
	scrapNum.text = str(Inventory.scrap)
	steelNum.text = str(Inventory.steel)
	circuitNum.text = str(Inventory.circuit)
	batteryNum.text = str(Inventory.battery)
	match activeCraftList[1]:
		"Wood", "Rock":
			gunNameLabel.text = "Crafting Handgun"
		"Scrap":
			gunNameLabel.text = "Crafting Shotgun"
		"Steel":
			gunNameLabel.text = "Crafting Sniper"
		"Battery", "Circuit":
			gunNameLabel.text = "Crafting AR"
		_:
			gunNameLabel.text = ""
func play_crafting_error_sfx() -> void:
	if visible and Global.craftActive:
		craftingmaterialerror_sfx.play()

func craftGun() -> void:
	if "Null" not in activeCraftList:
		craftingconfirm_sfx.play()
		Gun.craft(activeCraftList[0], activeCraftList[1], activeCraftList[2], activeCraftList[3])
		refund(5)
	else:
		play_crafting_error_sfx()

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
func updateHover() -> void:
	if activeItem == "Null":
		hoverItem.visible = false
		last_hover_item_for_sfx = "Null"
	else:
		hoverItem.visible = true
		if activeItem != last_hover_item_for_sfx:
			pickupcrafting_sfx.play()
			last_hover_item_for_sfx = activeItem
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
	else:
		play_crafting_error_sfx()
func rockPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.rock > 0:
		activeItem = "Rock"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Rock")
		activeItem = "Null"
	else:
		play_crafting_error_sfx()
func scrapPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.scrap > 0:
		activeItem = "Scrap"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Scrap")
		activeItem = "Null"
	else:
		play_crafting_error_sfx()
func steelPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.steel > 0:
		activeItem = "Steel"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Steel")
		activeItem = "Null"
	else:
		play_crafting_error_sfx()
func circuitPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.circuit > 0:
		activeItem = "Circuit"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Circuit")
		activeItem = "Null"
	else:
		play_crafting_error_sfx()
func batteryPick() -> void:
	await get_tree().create_timer(0.01, true).timeout
	if Inventory.battery > 0:
		activeItem = "Battery"
		while mousePressed != false:
			await get_tree().create_timer(0.05, true).timeout
		enterCheck("Battery")
		activeItem = "Null"
	else:
		play_crafting_error_sfx()

func enterCheck(arg: String) -> void:
	var was_dropped: bool = false
	if hHover == true:
		if activeCraftList[0] != "Null":
			refund(0)
		activeCraftList[0] = arg
		transact(arg)
		was_dropped = true
	elif cHover == true:
		if activeCraftList[1] != "Null":
			refund(1)
		activeCraftList[1] = arg
		transact(arg)
		was_dropped = true
	elif bHover == true:
		if activeCraftList[2] != "Null":
			refund(2)
		activeCraftList[2] = arg
		transact(arg)
		was_dropped = true
	elif mHover == true:
		if activeCraftList[3] != "Null":
			refund(3)
		activeCraftList[3] = arg
		transact(arg)
		was_dropped = true

	if was_dropped:
		dropmaterialcrafting_sfx.play()
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
		Global.cannotPauseCrafting = false
		reset_material_highlights()
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
