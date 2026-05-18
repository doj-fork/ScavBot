class_name Title
extends Node2D

const BGM_FADE_DURATION: float = 0.6
const BGM_SILENT_DB: float = -40.0
const PARALLAX_MAX_OFFSET: float = 100.0
const PARALLAX_FOLLOW_SPEED: float = 6.0
const PARALLAX_OVERSCAN_SCALE: float = 1.2
const INTRO_BLACK_HOLD_DURATION: float = 2.8
const INTRO_PRESENTS_FADE_IN_DURATION: float = 1.2
const INTRO_PRESENTS_HOLD_DURATION: float = 3.0
const INTRO_PRESENTS_FADE_OUT_DURATION: float = 0.8
const INTRO_TITLE_FADE_IN_DURATION: float = 1.1
const INTRO_BLACK_FADE_OUT_DURATION: float = 1.1
const LAYOUT_REGION_SIZE: Vector2 = Vector2(960.0, 540.0)

# 5/8/26 kind of fixed stuff will work on it more

@onready var menu_bgm: AudioStreamPlayer2D = $MenuBGM
@onready var play_button: Button = $UIRoot/CenterContainer/VBoxContainer/PlayButton
@onready var credits_button: Button = $UIRoot/CenterContainer/VBoxContainer/CreditsButton
@onready var quit_button: Button = $UIRoot/CenterContainer/VBoxContainer/QuitButton
@onready var hover_sfx: AudioStreamPlayer2D = $hoverSFX
@onready var click_sfx: AudioStreamPlayer2D = $clickSFX
@onready var parallax_ground: Sprite2D = $ParallaxGround
@onready var grain_overlay: ColorRect = $GrainOverlay
@onready var ui_root: Control = $UIRoot
@onready var intro_overlay: Control = $IntroOverlay
@onready var black_screen: ColorRect = $IntroOverlay/BlackScreen
@onready var group_presents_label: Label = $IntroOverlay/GroupPresentsLabel
@onready var credits_overlay: Control = $CreditsOverlay
@onready var close_button: Button = $CreditsOverlay/CloseButton
@onready var options_button: Button = $UIRoot/CenterContainer/VBoxContainer/OptionsButton
@onready var options_overlay: TitleOptions = $OptionsOverlay

var is_starting_game: bool = false
var is_intro_playing: bool = true
var bgm_fade_tween: Tween = null
var parallax_offset: Vector2 = Vector2.ZERO
var parallax_base_center: Vector2 = Vector2.ZERO


func _ready() -> void:
	Global.cannotCraftGeneral = true
	Global.cannotPauseGeneral = true
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

	_connect_button_signals()
	options_overlay.options_closed.connect(_on_options_closed)

	await _play_intro_sequence()


func _exit_tree() -> void:
	Global.cannotPauseGeneral = false


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

# ok it returns to menu but the game state doesn't get reset

func _play_intro_sequence() -> void:
	var skip_intro_once: bool = Global.skipTitleIntroOnce
	if skip_intro_once:
		Global.skipTitleIntroOnce = false

	var intro_black_hold_duration: float = 0.0 if skip_intro_once else INTRO_BLACK_HOLD_DURATION
	var intro_presents_fade_in_duration: float = 0.0 if skip_intro_once else INTRO_PRESENTS_FADE_IN_DURATION
	var intro_presents_hold_duration: float = 0.0 if skip_intro_once else INTRO_PRESENTS_HOLD_DURATION
	var intro_presents_fade_out_duration: float = 0.0 if skip_intro_once else INTRO_PRESENTS_FADE_OUT_DURATION
	var intro_title_fade_in_duration: float = 0.0 if skip_intro_once else INTRO_TITLE_FADE_IN_DURATION
	var intro_black_fade_out_duration: float = 0.0 if skip_intro_once else INTRO_BLACK_FADE_OUT_DURATION

	await get_tree().create_timer(intro_black_hold_duration).timeout

	var presents_fade_in_tween: Tween = create_tween()
	presents_fade_in_tween.tween_property(group_presents_label, "modulate:a", 1.0, intro_presents_fade_in_duration)
	await presents_fade_in_tween.finished

	await get_tree().create_timer(intro_presents_hold_duration).timeout

	var should_fade_in_bgm: bool = menu_bgm.stream != null
	if should_fade_in_bgm:
		menu_bgm.volume_db = BGM_SILENT_DB
		if not menu_bgm.playing:
			menu_bgm.play()

	var transition_tween: Tween = create_tween().set_parallel(true)
	transition_tween.tween_property(group_presents_label, "modulate:a", 0.0, intro_presents_fade_out_duration)
	transition_tween.tween_property(ui_root, "modulate:a", 1.0, intro_title_fade_in_duration)
	transition_tween.tween_property(black_screen, "color:a", 0.0, intro_black_fade_out_duration)
	if should_fade_in_bgm:
		transition_tween.tween_property(menu_bgm, "volume_db", 0.0, intro_black_fade_out_duration)
	await transition_tween.finished

	intro_overlay.visible = false
	is_intro_playing = false
	if not is_starting_game:
		play_button.disabled = false


func _on_menu_bgm_finished() -> void:
	if is_starting_game:
		return
	menu_bgm.play()


func _connect_button_signals() -> void:
	if not play_button.mouse_entered.is_connected(_on_button_hover):
		play_button.mouse_entered.connect(_on_button_hover)
	if not play_button.pressed.is_connected(_on_button_click):
		play_button.pressed.connect(_on_button_click)

	if not credits_button.mouse_entered.is_connected(_on_button_hover):
		credits_button.mouse_entered.connect(_on_button_hover)
	if not credits_button.pressed.is_connected(_on_button_click):
		credits_button.pressed.connect(_on_button_click)

	if not quit_button.mouse_entered.is_connected(_on_button_hover):
		quit_button.mouse_entered.connect(_on_button_hover)
	if not quit_button.pressed.is_connected(_on_button_click):
		quit_button.pressed.connect(_on_button_click)

	if not close_button.mouse_entered.is_connected(_on_button_hover):
		close_button.mouse_entered.connect(_on_button_hover)
	if not close_button.pressed.is_connected(_on_button_click):
		close_button.pressed.connect(_on_button_click)

	if not options_button.mouse_entered.is_connected(_on_button_hover):
		options_button.mouse_entered.connect(_on_button_hover)
	if not options_button.pressed.is_connected(_on_button_click):
		options_button.pressed.connect(_on_button_click)


func _on_button_hover() -> void:
	if hover_sfx.stream != null:
		hover_sfx.play()


func _on_button_click() -> void:
	if click_sfx.stream != null:
		click_sfx.play()


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
	Global.cannotCraftGeneral = false
	Global.cannotPauseGeneral = false
	Global.hudActive = true


func pressQuit() -> void:
	get_tree().quit()


func pressCredits() -> void:
	if is_intro_playing:
		return
	credits_overlay.visible = true


func pressCreditsClose() -> void:
	credits_overlay.visible = false


func pressOptions() -> void:
	if is_intro_playing:
		return
	play_button.disabled = true
	options_button.disabled = true
	credits_button.disabled = true
	quit_button.disabled = true
	options_overlay.open()


func _on_options_closed() -> void:
	if not is_starting_game:
		play_button.disabled = false
	options_button.disabled = false
	credits_button.disabled = false
	quit_button.disabled = false
