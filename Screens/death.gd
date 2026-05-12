class_name DeathScreen
extends Node2D

const FADE_DURATION: float = 3.2
const GRAIN_FADE_DURATION: float = 2.4
const FLASH_COUNT: int = 5
const FLASH_ON_DURATION: float = 0.14
const FLASH_OFF_DURATION: float = 0.1

@onready var black_fade: ColorRect = $OverlayLayer/BlackFade
@onready var grain_overlay: ColorRect = $OverlayLayer/GrainOverlay
@onready var connection_lost_label: RichTextLabel = $OverlayLayer/ConnectionLostLabel
@onready var retry_button: Button = $OverlayLayer/RetryButton
@onready var menu_button: Button = $OverlayLayer/MenuButton
@onready var hover_sfx: AudioStreamPlayer2D = $hoverSFX
@onready var click_sfx: AudioStreamPlayer2D = $clickSFX
@onready var static_sfx: AudioStreamPlayer2D = $staticSFX

var grain_material: ShaderMaterial = null


func _ready() -> void:
	randomize()
	_hide_hud()
	_setup_initial_state()
	await _play_death_sequence()


func _setup_initial_state() -> void:
	black_fade.color = Color(0.0, 0.0, 0.0, 0.0)
	grain_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	connection_lost_label.visible = false
	retry_button.visible = false
	retry_button.disabled = true
	menu_button.visible = false
	menu_button.disabled = true

	if grain_overlay.material is ShaderMaterial:
		grain_material = grain_overlay.material as ShaderMaterial
		if grain_material != null:
			grain_material.set_shader_parameter("seed", randf_range(0.0, 10000.0))
			grain_material.set_shader_parameter("intensity", 0.2)


func _play_death_sequence() -> void:
	var fade_tween: Tween = create_tween().set_parallel(true)
	fade_tween.tween_property(black_fade, "color:a", 1.0, FADE_DURATION)
	fade_tween.tween_property(grain_overlay, "modulate:a", 1.0, GRAIN_FADE_DURATION)
	if static_sfx.stream != null:
		static_sfx.play()
	await fade_tween.finished

	_stop_grain_noise()
	await _flash_connection_lost()

	retry_button.visible = true
	retry_button.disabled = false
	menu_button.visible = true
	menu_button.disabled = false
	_connect_button_signals()
	retry_button.grab_focus()


func _stop_grain_noise() -> void:
	if grain_material != null:
		grain_material.set_shader_parameter("intensity", 0.0)
	grain_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)


func _flash_connection_lost() -> void:
	for flash_index in range(FLASH_COUNT):
		connection_lost_label.visible = true
		connection_lost_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		await get_tree().create_timer(FLASH_ON_DURATION).timeout
		connection_lost_label.visible = false
		await get_tree().create_timer(FLASH_OFF_DURATION).timeout

	connection_lost_label.visible = true

# WORKS BUT THE MATERIALS, TIMER, ETC. CARRIES OVER

func _on_retry_button_pressed() -> void:
	retry_button.disabled = true
	menu_button.disabled = true
	Global.hudActive = true
	Stats.health = 100 + (Stats.healthMult * 5)
	get_tree().change_scene_to_file("res://Screens/game_loader.tscn")

# game starts tweaking when you press from the menu i might remove

func _on_menu_button_pressed() -> void:
	retry_button.disabled = true
	menu_button.disabled = true
	Global.hudActive = false
	var has_skip_property: bool = false
	for property_info: Dictionary in Global.get_property_list():
		if property_info.get("name", "") == "skipTitleIntroOnce":
			has_skip_property = true
			break
	if has_skip_property:
		Global.set("skipTitleIntroOnce", true)
	get_tree().change_scene_to_file("res://Screens/title.tscn")


func _connect_button_signals() -> void:
	if not retry_button.mouse_entered.is_connected(_on_button_hover):
		retry_button.mouse_entered.connect(_on_button_hover)
	if not retry_button.pressed.is_connected(_on_button_click):
		retry_button.pressed.connect(_on_button_click)

	if not menu_button.mouse_entered.is_connected(_on_button_hover):
		menu_button.mouse_entered.connect(_on_button_hover)
	if not menu_button.pressed.is_connected(_on_button_click):
		menu_button.pressed.connect(_on_button_click)


func _on_button_hover() -> void:
	if hover_sfx.stream != null:
		hover_sfx.play()


func _on_button_click() -> void:
	if click_sfx.stream != null:
		click_sfx.play()


func _hide_hud() -> void:
	Global.hudActive = false
	if Hud != null:
		Hud.visible = false
