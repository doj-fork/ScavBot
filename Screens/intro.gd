extends Node2D

@onready var label = $Text
var txt = "Yeah... imagine a really cool lore dump right now"

func _ready():
	label.visible = false
	label.text = txt
	label.visible_characters = 0
	
	await get_tree().create_timer(1.5, false).timeout
	runText()
	
func runText():
	label.visible = true
	for i in txt:
		label.visible_characters += 1
		if i in ["!", ".", "?"]:
			await get_tree().create_timer(0.25, false).timeout
		elif i in [","]:
			await get_tree().create_timer(0.125, false).timeout
		elif i in [" "]:
			await get_tree().create_timer(0.025, false).timeout
		else:
			await get_tree().create_timer(0.018, false).timeout
			
	await get_tree().create_timer(0.5, false).timeout
	closeText()

func closeText():
	var newTxt = txt
	while len(newTxt) > 1:
		var replacement = ""
		for i in newTxt:
			var burn = randi_range(0, 8)
			if burn != 0:
				replacement += i
				print(replacement)
		newTxt = replacement
		label.text = newTxt
		await get_tree().create_timer(0.025, false).timeout
	label.visible_characters = 0
	
	await get_tree().create_timer(1, false).timeout
	Transition.playTransition()
	await get_tree().create_timer(0.6, false).timeout
	get_tree().change_scene_to_file("res://Screens/map.tscn")
	
