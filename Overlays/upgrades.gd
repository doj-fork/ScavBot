extends CanvasLayer

func _ready():
	visible = false


func _on_health_pressed() -> void:
	Stats.health += 25
	Stats.healthMult += 5
	visible = false
	Global.hudActive = true

func _on_speed_pressed() -> void:
	Stats.speed += 25
	Stats.speedMult += 25
	visible = false
	Global.hudActive = true

func _on_damage_pressed() -> void:
	Stats.damageMult += 3
	visible = false
	Global.hudActive = true
