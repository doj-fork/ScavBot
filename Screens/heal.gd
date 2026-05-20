extends Node2D

var entered: bool = false
var _interacting: bool = false
var _flashTween: Tween = null

@onready var sprite: Sprite2D = $Sprite
@onready var interact_sound: AudioStreamPlayer2D = $InteractSound

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and entered and visible and not _interacting:
		_start_interact()

func _start_interact() -> void:
	_interacting = true
	_stopFlash()
	Global.cannotCraftCollecting = true
	Global.cannotShootCollecting = true
	var sfx_path: String = "res://Assets/SFX/UI/interact1.wav" if randi() % 2 == 0 else "res://Assets/SFX/UI/interact2.wav"
	interact_sound.volume_db = 0.0
	interact_sound.stream = load(sfx_path)
	interact_sound.play()
	await get_tree().create_timer(1.0, false).timeout
	Global.cannotCraftCollecting = false
	Global.cannotShootCollecting = false
	_interacting = false
	interact_sound.stream = load("res://Assets/SFX/UI/heal.mp3")
	interact_sound.volume_db = -15.0
	interact_sound.play()
	Signals.charge.emit()
	visible = false
	Stats.health += 50
	if Stats.health > (100 + Stats.healthMult * 5):
		Stats.health = (100 + Stats.healthMult * 5)

func areaEntered(_area: Area2D) -> void:
	entered = true
	if visible:
		_startFlash()

func areaExited(_area: Area2D) -> void:
	entered = false
	_stopFlash()

func _startFlash() -> void:
	if _flashTween:
		_flashTween.kill()
	_flashTween = create_tween().set_loops()
	_flashTween.tween_property(sprite, "modulate", Color(1.4, 1.4, 1.4, 1.0), 0.4)
	_flashTween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4)

func _stopFlash() -> void:
	if _flashTween:
		_flashTween.kill()
		_flashTween = null
	if is_instance_valid(sprite):
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
