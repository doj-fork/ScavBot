extends Node2D

@onready var animator = $AnimationPlayer
func _ready():
	Global.dead = false
	Signals.waveStart.emit()
	awaitGateOpen()
	
func awaitGateOpen():
	await Signals.waveEnd
	animator.play("OpenGate")
