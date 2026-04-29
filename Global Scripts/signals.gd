extends Node

signal chunkGen
signal waveStart
signal waveEnd

func runGen():
	chunkGen.emit()
	waveStart.emit()
	waveEnd.emit()
