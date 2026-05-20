extends CanvasLayer

@onready var hover_sfx: AudioStreamPlayer2D = $hoverSFX
@onready var click_sfx: AudioStreamPlayer2D = $clickSFX

func _ready():
	visible = false


func _on_button_hover() -> void:
	if hover_sfx.stream != null:
		hover_sfx.play()


func _on_button_click() -> void:
	if click_sfx.stream != null:
		click_sfx.play()


func _on_health_pressed() -> void:
	_on_button_click()
	Stats.health += 25
	Stats.healthMult += 5
	visible = false
	Global.hudActive = true

func _on_speed_pressed() -> void:
	_on_button_click()
	Stats.speed += 25
	Stats.speedMult += 25
	visible = false
	Global.hudActive = true

func _on_damage_pressed() -> void:
	_on_button_click()
	Stats.damageMult += 3
	visible = false
	Global.hudActive = true
