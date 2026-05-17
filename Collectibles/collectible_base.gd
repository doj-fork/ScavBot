extends Node2D
class_name CollectibleBase

var health: int = 1
var cooldown: bool = false
var entered: bool = false
var _depleted: bool = false
var _flashTween: Tween = null

@onready var sprite: Sprite2D = $Sprite
@onready var interactSound: AudioStreamPlayer2D = $InteractSound
@onready var collectSound: AudioStreamPlayer2D = $CollectSound

func _ready() -> void:
	_setup()

func _setup() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and not cooldown and not _depleted and entered and not Global.cannotCraftCollecting:
		_startCollect()

func _startCollect() -> void:
	Global.cannotShootIntermission = true
	Global.cannotCraftCollecting = true
	cooldown = true
	Global.canMove += 1
	var sfxPath: String = "res://Assets/SFX/UI/interact1.wav" if randi() % 2 == 0 else "res://Assets/SFX/UI/interact2.wav"
	interactSound.stream = load(sfxPath)
	interactSound.play()
	await get_tree().create_timer(1.0, false).timeout
	cooldown = false
	health -= 1
	_giveResources()
	if health <= 0:
		_depleted = true
		_stopFlash()
		collectSound.play()
		Global.cannotShootIntermission = false
		Global.cannotCraftCollecting = false
		Global.canMove -= 1
		var fadeTween: Tween = create_tween()
		fadeTween.tween_property(sprite, "modulate:a", 0.0, 0.6)
		await fadeTween.finished
		sprite.visible = false
		await collectSound.finished
		queue_free()
	else:
		Global.cannotShootIntermission = false
		Global.cannotCraftCollecting = false
		Global.canMove -= 1

func _giveResources() -> void:
	pass

func areaEntered(_area: Area2D) -> void:
	entered = true
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
