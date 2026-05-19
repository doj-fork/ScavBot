extends Node

signal chunkGen
signal waveStart
signal waveEnd
signal intermission
signal craft
signal charge
signal collecting
signal gun_crafted

func runGen():
	chunkGen.emit()
	waveStart.emit()
	waveEnd.emit()
	intermission.emit()
	collecting.emit()
	charge.emit()
	craft.emit()
