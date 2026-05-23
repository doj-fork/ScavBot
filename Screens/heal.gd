extends Node2D

var entered: bool = false
var _interacting: bool = false
var _flashTween: Tween = null
var _prompt_label: Label = null

@onready var sprite: Sprite2D = $Sprite
@onready var interact_sound: AudioStreamPlayer2D = $InteractSound

func _ready() -> void:
	_create_prompt_label()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and entered and visible and not _interacting:
		_start_interact()

func _start_interact() -> void:
	_hide_prompt()
	_interacting = true
	_stopFlash()
	Signals.charge.emit()
	Global.canMove += 1
	Global.cannotCraftCollecting = true
	Global.cannotShootCollecting = true
	var sfx_path: String = "res://Assets/SFX/UI/interact1.wav" if randi() % 2 == 0 else "res://Assets/SFX/UI/interact2.wav"
	interact_sound.volume_db = 0.0
	interact_sound.stream = load(sfx_path)
	interact_sound.play()
	await get_tree().create_timer(1.0, false).timeout
	Global.cannotCraftCollecting = false
	Global.cannotShootCollecting = false
	Global.canMove -= 1
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
		_show_prompt("Press [E]")

func areaExited(_area: Area2D) -> void:
	entered = false
	_stopFlash()
	_hide_prompt()

func _create_prompt_label() -> void:
	_prompt_label = Label.new()
	_prompt_label.add_theme_font_override("font", load("res://Assets/Fonts/SunkenMini.ttf"))
	_prompt_label.add_theme_font_size_override("font_size", 32)
	_prompt_label.add_theme_color_override("font_color", Color.WHITE)
	_prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_prompt_label.add_theme_constant_override("outline_size", 3)
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.custom_minimum_size = Vector2(200, 0)
	_prompt_label.visible = false
	add_child(_prompt_label)

func _show_prompt(text: String) -> void:
	if _prompt_label == null:
		return
	_prompt_label.text = text
	var visual_pos: Vector2 = sprite.position + Vector2(
		sprite.offset.x * sprite.scale.x,
		sprite.offset.y * sprite.scale.y
	)
	_prompt_label.position = visual_pos + Vector2(-100, -60)
	_prompt_label.visible = true

func _hide_prompt() -> void:
	if _prompt_label != null:
		_prompt_label.visible = false

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
