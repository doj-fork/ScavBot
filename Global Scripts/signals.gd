extends Node

signal chunkGen
signal waveStart
signal waveEnd
signal intermission

func runGen():
	chunkGen.emit()
	waveStart.emit()
	waveEnd.emit()
	intermission.emit()
