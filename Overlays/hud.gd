extends CanvasLayer

@onready var health = $Health
@onready var gun = $GunType
@onready var ammo = $Ammo
@onready var waveTimer = $WaveTimer

func _ready():
	gun.text = " "
	waveCountdown()
	
func _process(_delta):
	if Global.hudActive == false or Global.craftActive == true:
		visible = false
	else:
		visible = true
	health.text = " Energy: " + str(Stats.health)
	ammo.text = " " + str(Gun.ammo)
	
	if Gun.ammo > 0:
		ammo.visible = true
		gun.visible = true
	else:
		ammo.visible = false
		gun.visible = false

func waveCountdown():
	await Signals.waveStart
	for i in range(60, 0, -1):
		waveTimer.text = " Wave ends in " + str(i) + " seconds"
		await get_tree().create_timer(1, false).timeout
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
	waveTimer.text = "Exit has been cleared. Head north."
	waveTimer.visible_characters = 0
	for i in range(len(waveTimer.text)):
		print(waveTimer.text)
		waveTimer.visible_characters += 1
		await get_tree().create_timer(0.03, false).timeout
	await Signals.intermission
	waveTimer.text = ""
