extends CanvasLayer

@onready var animator = $AnimationPlayer

func _ready():
	visible = false
	
func playTransition():
	animator.play("Fade")
