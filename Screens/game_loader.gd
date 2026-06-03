extends Node2D

@onready var animator = $AnimationPlayer
@onready var _gate1_flare: Node2D = $Gate1/FlareNode
@onready var _gate2_flare: Node2D = $Gate2/FlareNode
@onready var _gate1_flarespr: Sprite2D = $Gate1/FlareNode/FlareSpr
@onready var _gate2_flarespr: Sprite2D = $Gate2/FlareNode/FlareSpr
@onready var _gate1_glow: Sprite2D = $Gate1/FlareNode/Glow
@onready var _gate2_glow: Sprite2D = $Gate2/FlareNode/Glow
@onready var _flare_sound: AudioStreamPlayer2D = $FlareSound

var _flare_tex: Array = [
	preload("res://Assets/NatureAssets/Flare1.png"),
	preload("res://Assets/NatureAssets/Flare2.png"),
	preload("res://Assets/NatureAssets/Flare3.png")
]
var _flares_active: bool = false

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
	_startFlares()

func _startFlares() -> void:
	_flares_active = true
	_flare_sound.play()
	var tween = create_tween().set_parallel()
	tween.tween_property(_gate1_flare, "modulate:a", 1.0, 0.5)
	tween.tween_property(_gate2_flare, "modulate:a", 1.0, 0.5)
	_cycleFlares()

func _cycleFlares() -> void:
	var i: int = 0
	while _flares_active and is_inside_tree():
		_gate1_flarespr.texture = _flare_tex[i]
		_gate2_flarespr.texture = _flare_tex[i]
		_gate1_glow.texture = _flare_tex[i]
		_gate2_glow.texture = _flare_tex[i]
		await get_tree().create_timer(0.25, false).timeout
		i = (i + 1) % 3
