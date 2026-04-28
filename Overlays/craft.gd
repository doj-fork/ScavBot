extends CanvasLayer

@onready var woodNum = $Text/WoodNum
@onready var rockNum = $Text/RockNum
@onready var scrapNum = $Text/ScrapNum
@onready var steelNum = $Text/SteelNum
@onready var circuitNum = $Text/CircuitNum
@onready var batteryNum = $Text/BatteryNum

var woodActive = false
var rockActive = false
var scrapActive = false
var steelActive = false
var circuitActive = false
var batteryActive = false

var hHover = false
var cHover = false
var bHover = false
var mHover = false

#Handle, Chamber, Barrel, Muzzle
var activeCraftList = ["Null", "Null", "Null", "Null"]
var activeItem = "Null"

func _ready():
	visible = false
	
func _process(_delta):
	if Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == false:
		visible = true
		Global.craftActive = true
		get_tree().paused = true
	elif Input.is_action_just_pressed("Craft") and true not in Global.cannotCraftList and Global.craftActive == true:
		visible = false
		Global.craftActive = false
		get_tree().paused = false
		
	updateText()
	
	
	
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
		visible = false
		Global.craftActive = false
		get_tree().paused = false


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
	if Inventory.wood > 0:
		print(activeItem)
		while Input.is_action_just_released("Click") == false:
			activeItem = "Wood"
			await get_tree().create_timer(0.05, false).timeout
			
		print("End")
		activeItem = "Null"
func rockPick() -> void:
	pass

func stonePick() -> void:
	pass # Replace with function body.

func steelPick() -> void:
	pass # Replace with function body.

func circuitPick() -> void:
	pass # Replace with function body.

func batteryPick() -> void:
	pass # Replace with function body.
