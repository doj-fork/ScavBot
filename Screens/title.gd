class_name Title
extends Node2D

const BGM_FADE_DURATION: float = 0.6
const BGM_SILENT_DB: float = -40.0
const PARALLAX_MAX_OFFSET: float = 30.0
const PARALLAX_FOLLOW_SPEED: float = 6.0
const PARALLAX_OVERSCAN_SCALE: float = 1.2
const INTRO_BLACK_HOLD_DURATION: float = 2.8
const INTRO_PRESENTS_FADE_IN_DURATION: float = 1.2
const INTRO_PRESENTS_HOLD_DURATION: float = 3.0
const INTRO_PRESENTS_FADE_OUT_DURATION: float = 0.8
const INTRO_TITLE_FADE_IN_DURATION: float = 1.1
const INTRO_BLACK_FADE_OUT_DURATION: float = 1.1
const LAYOUT_REGION_SIZE: Vector2 = Vector2(960.0, 540.0)

# i was losing my mind over this i will fix the issues sometime between the 8th and 10th

@onready var menu_bgm: AudioStreamPlayer2D = $MenuBGM
@onready var play_button: Button = $UIRoot/CenterContainer/VBoxContainer/PlayButton
@onready var parallax_ground: Sprite2D = $ParallaxGround
@onready var grain_overlay: ColorRect = $GrainOverlay
@onready var ui_root: Control = $UIRoot
@onready var intro_overlay: Control = $IntroOverlay
@onready var black_screen: ColorRect = $IntroOverlay/BlackScreen
@onready var group_presents_label: Label = $IntroOverlay/GroupPresentsLabel

var is_starting_game: bool = false
var is_intro_playing: bool = true
var bgm_fade_tween: Tween = null
var parallax_offset: Vector2 = Vector2.ZERO
var parallax_base_center: Vector2 = Vector2.ZERO


func _ready() -> void:
	parallax_base_center = parallax_ground.position
	_fit_background_to_viewport()
	var viewport: Viewport = get_viewport()
	if not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)

	ui_root.modulate = Color(1, 1, 1, 0)
	group_presents_label.modulate = Color(1, 1, 1, 0)
	black_screen.color = Color(0, 0, 0, 1)
	intro_overlay.visible = true
	play_button.disabled = true

	await _play_intro_sequence()


func _process(delta: float) -> void:
	if LAYOUT_REGION_SIZE == Vector2.ZERO:
		return

	var region_origin: Vector2 = parallax_base_center - (LAYOUT_REGION_SIZE * 0.5)
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var local_mouse: Vector2 = (mouse_position - region_origin)
	var normalized_mouse: Vector2 = (local_mouse / LAYOUT_REGION_SIZE) - Vector2(0.5, 0.5)
	normalized_mouse.x = clampf(normalized_mouse.x, -0.5, 0.5)
	normalized_mouse.y = clampf(normalized_mouse.y, -0.5, 0.5)
	var target_offset: Vector2 = normalized_mouse * PARALLAX_MAX_OFFSET
	var follow_weight: float = clampf(delta * PARALLAX_FOLLOW_SPEED, 0.0, 1.0)
	parallax_offset = parallax_offset.lerp(target_offset, follow_weight)
	parallax_ground.position = parallax_base_center - parallax_offset


func _on_viewport_size_changed() -> void:
	_fit_background_to_viewport()

func _fit_background_to_viewport() -> void:
	if parallax_ground.texture == null:
		return

	var texture_size: Vector2 = parallax_ground.texture.get_size()
	if texture_size == Vector2.ZERO:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var region_size: Vector2 = Vector2(960.0, 540.0)
	var region_origin: Vector2 = viewport_size - region_size
	region_origin.x = maxf(region_origin.x, 0.0)
	region_origin.y = maxf(region_origin.y, 0.0)
	var scale_factor: float = maxf(region_size.x / texture_size.x, region_size.y / texture_size.y)
	scale_factor *= PARALLAX_OVERSCAN_SCALE
	parallax_ground.scale = Vector2.ONE * scale_factor
	parallax_ground.position = region_origin + (region_size * 0.5)
	parallax_offset = Vector2.ZERO


func _play_intro_sequence() -> void:
	await get_tree().create_timer(INTRO_BLACK_HOLD_DURATION).timeout

	var presents_fade_in_tween: Tween = create_tween()
	presents_fade_in_tween.tween_property(group_presents_label, "modulate:a", 1.0, INTRO_PRESENTS_FADE_IN_DURATION)
	await presents_fade_in_tween.finished

	await get_tree().create_timer(INTRO_PRESENTS_HOLD_DURATION).timeout

	var should_fade_in_bgm: bool = menu_bgm.stream != null
	if should_fade_in_bgm:
		menu_bgm.volume_db = BGM_SILENT_DB
		if not menu_bgm.playing:
			menu_bgm.play()

	var transition_tween: Tween = create_tween().set_parallel(true)
	transition_tween.tween_property(group_presents_label, "modulate:a", 0.0, INTRO_PRESENTS_FADE_OUT_DURATION)
	transition_tween.tween_property(ui_root, "modulate:a", 1.0, INTRO_TITLE_FADE_IN_DURATION)
	transition_tween.tween_property(black_screen, "color:a", 0.0, INTRO_BLACK_FADE_OUT_DURATION)
	if should_fade_in_bgm:
		transition_tween.tween_property(menu_bgm, "volume_db", 0.0, INTRO_BLACK_FADE_OUT_DURATION)
	await transition_tween.finished

	intro_overlay.visible = false
	is_intro_playing = false
	if not is_starting_game:
		play_button.disabled = false


func _on_menu_bgm_finished() -> void:
	if is_starting_game:
		return
	menu_bgm.play()


func pressPlay() -> void:
	if is_starting_game or is_intro_playing:
		return

	is_starting_game = true
	play_button.disabled = true
	var transition_node: Node = get_tree().root.get_node_or_null("Transition")
	if transition_node != null and transition_node.has_method("playTransition"):
		transition_node.call("playTransition")

	if bgm_fade_tween != null and bgm_fade_tween.is_valid():
		bgm_fade_tween.kill()

	bgm_fade_tween = create_tween()
	bgm_fade_tween.tween_property(menu_bgm, "volume_db", BGM_SILENT_DB, BGM_FADE_DURATION)
	await bgm_fade_tween.finished
	menu_bgm.stop()

	get_tree().change_scene_to_file("res://Screens/game_loader.tscn")
	Global.hudActive = true
