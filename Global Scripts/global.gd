extends Node

var playerPos = Vector2(0, 0)

var canMove = 0

var hudActive = false
var craftActive = false
var pauseActive = false

var cannotPauseTransitioning = false
var cannotPauseGeneral = false
var cannotPauseCrafting = false
var cannotPauseList = [cannotPauseTransitioning, cannotPauseGeneral, cannotPauseCrafting]

var cannotCraftGeneral = false
var cannotCraftList = [cannotCraftGeneral]

func _process(_delta):
	cannotPauseList = [cannotPauseTransitioning, cannotPauseGeneral, cannotPauseCrafting]
	cannotCraftList = [cannotCraftGeneral]
