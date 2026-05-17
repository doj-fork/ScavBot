class_name TitleOptions
extends CanvasLayer

signal options_closed

@onready var _sfx_music_label: RichTextLabel = $Text
@onready var _hover_sfx: AudioStreamPlayer2D = $hoverSFX
@onready var _click_sfx: AudioStreamPlayer2D = $clickSFX

func _ready() -> void:
	visible = false
	_refresh_volume_label()

func open() -> void:
	visible = true
	_refresh_volume_label()

func close() -> void:
	visible = false
	options_closed.emit()

func _on_main_menu_pressed() -> void:
	_play_click()
	close()

func _on_windowed_pressed() -> void:
	_play_click()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_fullscreen_pressed() -> void:
	_play_click()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_bgm_up_pressed() -> void:
	_play_click()
	Stats.music_volume = min(Stats.music_volume + 1, 10)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _on_bgm_down_pressed() -> void:
	_play_click()
	Stats.music_volume = max(Stats.music_volume - 1, 0)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _on_sfx_up_pressed() -> void:
	_play_click()
	Stats.sfx_volume = min(Stats.sfx_volume + 1, 10)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _on_sfx_down_pressed() -> void:
	_play_click()
	Stats.sfx_volume = max(Stats.sfx_volume - 1, 0)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _on_button_hover() -> void:
	if _hover_sfx.stream != null:
		_hover_sfx.play()

func _play_click() -> void:
	if _click_sfx.stream != null:
		_click_sfx.play()

func _refresh_volume_label() -> void:
	_sfx_music_label.text = "SFX: " + str(Stats.sfx_volume) + "\n\nBGM: " + str(Stats.music_volume)
