extends Node2D

@onready var animator = $AnimationPlayer

func _ready():
	Global.currentEnemies = 0
	Stats.wave += 1
	Global.dead = false
	BGM.play_game_bgm()
	Signals.waveStart.emit()
	awaitGateOpen()
	Global.inGame = true
	
func awaitGateOpen():
	await Signals.waveEnd
	animator.play("OpenGate")
