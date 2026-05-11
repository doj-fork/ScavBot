class_name GlobalState
extends Node

var playerPos: Vector2 = Vector2.ZERO

var canMove: int = 0

var hudActive: bool = false
var craftActive: bool = false
var pauseActive: bool = false
var skipTitleIntroOnce: bool = false

var cannotPauseTransitioning: bool = false
var cannotPauseGeneral: bool = false
var cannotPauseCrafting: bool = false
var cannotPauseList: Array[bool] = [cannotPauseTransitioning, cannotPauseGeneral, cannotPauseCrafting]

var cannotCraftGeneral: bool = false
var cannotCraftCollecting: bool = false
var cannotCraftList: Array[bool] = [cannotCraftGeneral, cannotCraftCollecting]

func _process(_delta: float) -> void:
	cannotPauseList = [cannotPauseTransitioning, cannotPauseGeneral, cannotPauseCrafting]
	cannotCraftList = [cannotCraftGeneral, cannotCraftCollecting]
