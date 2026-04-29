extends CanvasLayer

@onready var health = $Health
@onready var gun = $GunType
@onready var ammo = $Ammo
@onready var waveTimer = $WaveTimer

func _ready():
	waveCountdown()
	
func _process(_delta):
	if Global.hudActive == false or Global.craftActive == true:
		visible = false
	else:
		visible = true

	health.text = " Energy: " + str(Stats.health)
	gun.text = " " + Gun.type
	ammo.text = " " + str(Gun.ammo)

func waveCountdown():
	await Signals.waveStart
	for i in range(60, 0, -1):
		waveTimer.text = " Wave ends in " + str(i) + " seconds"
		await get_tree().create_timer(1, false).timeout
	Signals.waveEnd.emit()
	waveTimer.text = "Get Out!"
	waveCountdown()
	
