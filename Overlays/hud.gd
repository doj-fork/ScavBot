extends CanvasLayer

@onready var battery = $Battery
@onready var health = $Battery/Health
@onready var gun = $GunType
@onready var ammo = $Ammo
@onready var waveTimer = $WaveTimer
@onready var bulletIcon = $BulletIcon
@onready var reloadIcon = $ReloadIcon
@onready var tutorial_dialogue: Label = $TutorialDialogue
@onready var tutorial_speaker: Label = $TutorialSpeaker

func _ready():
	gun.text = " "
	waveCountdown()
	reloadIcon.frame = 0

func _process(_delta):
	if Global.hudActive == false or Global.craftActive == true:
		visible = false
	else:
		visible = true
	health.text = str(Stats.health)
	ammo.text = " " + str(Gun.ammo) + " / " + str(Global.bulletMax)
	
	if Stats.health > 75:
		health.add_theme_color_override("font_outline_color", Color(0.098, 0.549, 0.326, 1.0))
		battery.texture = load("res://Assets/HUD/HUDBattery100.png")
	elif Stats.health > 50:
		health.add_theme_color_override("font_outline_color", Color(0.307, 0.499, 0.082, 1.0))
		battery.texture = load("res://Assets/HUD/HUDBattery75.png")
	elif Stats.health > 25:
		health.add_theme_color_override("font_outline_color", Color(0.583, 0.505, 0.0, 1.0))
		battery.texture = load("res://Assets/HUD/HUDBattery50.png")
	elif Stats.health > 0:
		health.add_theme_color_override("font_outline_color", Color(0.507, 0.052, 0.061, 1.0))
		battery.texture = load("res://Assets/HUD/HUDBattery25.png")
		
	if Gun.ammo > 0:
		ammo.visible = true
		gun.visible = true
		if Gun.type != "AR":
			bulletIcon.visible = true
			reloadIcon.visible = true
		else:
			bulletIcon.visible = false
			reloadIcon.visible = false
	else:
		ammo.visible = false
		gun.visible = false
		bulletIcon.visible = false
		reloadIcon.visible = false

func waveCountdown():
	await Signals.waveStart
	var countdown = 60
	while countdown > 0 and Global.dead == false:
		waveTimer.text = " Wave ends in " + str(countdown) + " seconds"
		await get_tree().create_timer(1, false).timeout
		countdown -= 1
	Signals.waveEnd.emit()
	waveEnd()
	waveCountdown()

func gunCraft(arg):
	gun.visible_characters = 0
	gun.text = " " + arg
	for i in range(len(arg) + 1):
		gun.visible_characters += 1
		await get_tree().create_timer(0.05, false).timeout

func waveEnd():
	waveTimer.text = " Exit has been cleared. Head north."
	waveTimer.visible_characters = 0
	for i in range(len(waveTimer.text)):
		print(waveTimer.text)
		waveTimer.visible_characters += 1
		await get_tree().create_timer(0.03, false).timeout
	await Signals.intermission
	waveTimer.text = ""

func _on_craft_button_pressed() -> void:
	if true not in Global.cannotCraftList and Global.craftActive == false and Global.pauseActive == false:
		Crafting.openCraft()

func reloadGun():
	var reloadTime = 0
	if Gun.type == "Shotgun":
		reloadTime = 1
	elif Gun.type == "Sniper":
		reloadTime = 1.2
	elif Gun.type == "Handgun":
		reloadTime = 0.25
	for i in range(8, -1, -1):
		reloadIcon.frame = i
		await get_tree().create_timer(reloadTime / 9.0, false).timeout
