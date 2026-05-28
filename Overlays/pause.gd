extends CanvasLayer

var active = false

@onready var _hostiles_killed_label: RichTextLabel = $HostilesKilled
@onready var _sfx_music_label: RichTextLabel = $Text
@onready var _hover_sfx: AudioStreamPlayer2D = $hoverSFX
@onready var _click_sfx: AudioStreamPlayer2D = $clickSFX

func _ready():
	visible = false
	_refresh_volume_label()
	
func _process(_delta):
	if Input.is_action_just_pressed("Escape") and true not in Global.cannotPauseList and active == false:
		active = true
		Global.pauseActive = true
		visible = true
		Global.cannotCraftPaused = true
		get_tree().paused = true
		_update_hostiles_killed()
		_refresh_volume_label()
		await get_tree().create_timer(0.1, false).timeout
	elif Input.is_action_just_pressed("Escape") and true not in Global.cannotPauseList and active == true:
		resume()
		
func resume():
	active = false
	Global.pauseActive = false
	Global.cannotCraftPaused = false
	visible = false
	get_tree().paused = false
	
func _on_menu_pressed() -> void:
	Stats.majorReset()
	resume()
	Transition.playTransition()
	BGM.stop_immediate()
	await get_tree().create_timer(0.6, false).timeout
	Global.set("skipTitleIntroOnce", true)
	Global.hudActive = false
	Global.dead = true
	get_tree().change_scene_to_file("res://Screens/title.tscn")
	

func _on_quit_pressed() -> void:
	get_tree().quit()
	
func _on_resume_pressed() -> void:
	resume()

func _on_windowed_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_music_down_pressed() -> void:
	Stats.music_volume = max(Stats.music_volume - 1, 0)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _on_music_up_pressed() -> void:
	Stats.music_volume = min(Stats.music_volume + 1, 10)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _on_sfx_up_pressed() -> void:
	Stats.sfx_volume = min(Stats.sfx_volume + 1, 10)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _on_sfx_down_pressed() -> void:
	Stats.sfx_volume = max(Stats.sfx_volume - 1, 0)
	BGM._apply_bus_volumes()
	_refresh_volume_label()

func _refresh_volume_label() -> void:
	_sfx_music_label.text = "SFX: " + str(Stats.sfx_volume) + "\n\nBGM: " + str(Stats.music_volume)

func _update_hostiles_killed() -> void:
	var total: int = Stats.melee_kills + Stats.ranger_kills + Stats.tank_kills
	if total > 999999:
		_hostiles_killed_label.text = "Hostiles Killed: Endless"
	else:
		_hostiles_killed_label.text = "Hostiles Killed: " + _format_kills(total)

func _format_kills(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result


func _on_button_hover() -> void:
	if _hover_sfx.stream != null:
		_hover_sfx.play()


func _on_button_click() -> void:
	if _click_sfx.stream != null:
		_click_sfx.play()
