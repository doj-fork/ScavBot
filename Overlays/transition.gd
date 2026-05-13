extends CanvasLayer

@onready var animator = $AnimationPlayer

func _ready():
	visible = false
	
func playTransition():
	Global.cannotPauseTransitioning = true
	animator.play("Fade")
	await get_tree().create_timer(1.2, false).timeout
	Global.cannotPauseTransitioning = false
