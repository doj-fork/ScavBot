extends CanvasLayer

var active = false

@onready var _hostiles_killed_label: RichTextLabel = $HostilesKilled
@onready var _sfx_music_label: RichTextLabel = $Text

func _ready():
	visible = false
	_refresh_volume_label()
	
func _process(_delta):
	if Input.is_action_just_pressed("Escape") and true not in Global.cannotPauseList and active == false:
		active = true
		visible = true
		get_tree().paused = true
		_update_hostiles_killed()
		_refresh_volume_label()
	elif Input.is_action_just_pressed("Escape") and true not in Global.cannotPauseList and active == true:
		resume()
		
func resume():
	active = false
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
	_apply_music_volume()
	_refresh_volume_label()

func _on_music_up_pressed() -> void:
	Stats.music_volume = min(Stats.music_volume + 1, 10)
	_apply_music_volume()
	_refresh_volume_label()

func _on_sfx_up_pressed() -> void:
	Stats.sfx_volume = min(Stats.sfx_volume + 1, 10)
	_apply_sfx_volume()
	_refresh_volume_label()

func _on_sfx_down_pressed() -> void:
	Stats.sfx_volume = max(Stats.sfx_volume - 1, 0)
	_apply_sfx_volume()
	_refresh_volume_label()

func _apply_sfx_volume() -> void:
	var idx: int = AudioServer.get_bus_index("SFX")
	if idx == -1:
		return
	if Stats.sfx_volume == 0:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(float(Stats.sfx_volume) / 5.0))

func _apply_music_volume() -> void:
	var idx: int = AudioServer.get_bus_index("Music")
	if idx == -1:
		return
	if Stats.music_volume == 0:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(float(Stats.music_volume) / 5.0))

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
