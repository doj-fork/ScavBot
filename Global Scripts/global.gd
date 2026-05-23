class_name GlobalState
extends Node

var maxEnemies = 16
var currentEnemies = 0


var bulletMax = 0
var dead = false
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

var cannotShootGeneral: bool = false
var cannotShootIntermission: bool = false
var cannotShootCollecting: bool = false
var cannotShootList: Array[bool] = [cannotShootCollecting, cannotShootIntermission]

var cannotCraftGeneral: bool = false
var cannotCraftTransitioning: bool = false
var cannotCraftCollecting: bool = false
var cannotCraftPaused: bool = false
var cannotCraftList: Array[bool] = [cannotCraftGeneral, cannotCraftTransitioning, cannotCraftCollecting, cannotCraftPaused]

var tutorial_prompt_shown: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(_delta: float) -> void:
	maxEnemies = (16 + (2 * Stats.wave))
	
	cannotPauseList = [cannotPauseTransitioning, cannotPauseGeneral, cannotPauseCrafting]
	cannotCraftList = [cannotCraftGeneral, cannotCraftTransitioning, cannotCraftCollecting, cannotCraftPaused]
	cannotShootList = [cannotShootCollecting, cannotShootIntermission, cannotShootGeneral]
