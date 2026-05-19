extends Node

signal chunkGen
signal waveStart
signal waveEnd
signal intermission
signal charge
signal collecting

func runGen():
	chunkGen.emit()
	waveStart.emit()
	waveEnd.emit()
	intermission.emit()
	collecting.emit()
	charge.emit()
