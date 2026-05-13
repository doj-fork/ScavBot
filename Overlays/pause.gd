extends CanvasLayer

var active = false

func _ready():
	visible = false
	
func _process(_delta):
	if Input.is_action_just_pressed("Escape") and true not in Global.cannotPauseList and active == false:
		active = true
		visible = true
		get_tree().paused = true
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
	pass # Replace with function body.

func _on_music_up_pressed() -> void:
	pass # Replace with function body.

func _on_sfx_up_pressed() -> void:
	pass # Replace with function body.

func _on_sfx_down_pressed() -> void:
	pass # Replace with function body.
