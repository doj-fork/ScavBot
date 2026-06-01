extends RichTextLabel

func _ready():
	awaitHide()
	awaitShow()
	
func awaitHide():
	await Signals.hideText
	visible = false
	awaitHide()
	
func awaitShow():
	await Signals.waveStart
	visible = true
	awaitShow()
