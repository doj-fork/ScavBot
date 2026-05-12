extends Node2D

func _ready():
	Global.dead = false
	Signals.waveStart.emit()
