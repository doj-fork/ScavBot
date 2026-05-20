extends Node2D

var entered: bool = false
var _entering: bool = false
var _flashTween: Tween = null

@onready var sprite: Sprite2D = $Sprite
@onready var door_sound: AudioStreamPlayer2D = $DoorSound

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and entered and visible and not _entering:
		_entering = true
		door_sound.play()
		Signals.intermission.emit()
		BGM.fade_out()
		Transition.playTransition()
		await get_tree().create_timer(0.6, false).timeout
		get_tree().change_scene_to_file.call_deferred("res://Screens/intermission.tscn")

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
