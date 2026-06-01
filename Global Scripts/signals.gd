extends Node

signal chunkGen
signal waveStart
signal waveEnd
signal intermission
signal craft
signal charge
signal collecting
signal gun_crafted
signal hideText

func runGen():
	# this is only for debug purposes. whenever i load the game it says "none of the signals you declared are
	# used! so this function is just to get rid of that. do NOT call it 
	chunkGen.emit()
	waveStart.emit()
	waveEnd.emit()
	intermission.emit()
	collecting.emit()
	charge.emit()
	craft.emit()
	gun_crafted.emit()
	hideText.emit()
