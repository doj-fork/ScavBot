extends CharacterBody2D

@onready var animTree = $AnimationTree
@onready var stateMachine = animTree.get("parameters/playback")
@onready var walkSFX: AudioStreamPlayer2D = $walkSFX

var immunity: bool = false

var inputDir: Vector2 = Vector2(0, 0)
var animDir: Vector2 = Vector2(0, 0)

const WALK_SOUNDS: Array[String] = [
	"res://Assets/SFX/Player/walk1.wav",
	"res://Assets/SFX/Player/walk2.wav",
	"res://Assets/SFX/Player/walk3.wav",
	"res://Assets/SFX/Player/walk4.wav",
	"res://Assets/SFX/Player/walk5.wav"
]
const WALK_SOUND_INTERVAL: float = 1.4

var walkSoundTimer: float = 0.0
var isWalking: bool = false

func _process(_delta):
	Global.playerPos = global_position
	inputDir = (Vector2(Input.get_action_strength("Right") - Input.get_action_strength("Left"), Input.get_action_strength("Down") - Input.get_action_strength("Up"))).normalized()
	velocity = inputDir * Stats.speed
	if inputDir != Vector2(0, 0):
		animDir = inputDir
	animUpdate()
	play_walk_sound()
	if Global.canMove == 0:
		move_and_slide()
	
	if Stats.health < 1:
		get_tree().change_scene_to_file.call_deferred("res://Screens/death.tscn")

func animUpdate():
	animTree.set("parameters/Idle/blend_position", animDir)
	animTree.set("parameters/Walk/blend_position", animDir)
	
	if velocity != Vector2(0, 0):
		stateMachine.travel("Walk")
	elif velocity == Vector2(0, 0):
		stateMachine.travel("Idle")

func play_walk_sound() -> void:
	# Determine if player is walking
	var currentlyWalking: bool = velocity != Vector2(0, 0)
	
	# If walking state changed, reset timer
	if currentlyWalking != isWalking:
		isWalking = currentlyWalking
		walkSoundTimer = 0.0
	
	# Play sound if in walking state and timer is up
	if isWalking:
		walkSoundTimer -= get_physics_process_delta_time()
		if walkSoundTimer <= 0.0:
			var randomIndex: int = randi() % WALK_SOUNDS.size()
			var soundPath: String = WALK_SOUNDS[randomIndex]
			walkSFX.stream = load(soundPath)
			walkSFX.play()
			walkSoundTimer = WALK_SOUND_INTERVAL

func _on_area_2d_area_entered(area: Area2D) -> void:
	if immunity == false:
		immunity = true
		Stats.health -= 10 + (3 * Stats.damageMult)
		var enemy: Node = area.get_parent()
		if enemy.has_method("_triggerPlayerHitRetreat"):
			enemy._triggerPlayerHitRetreat()
		if enemy.has_method("_triggerPlayerHitSlowdown"):
			enemy._triggerPlayerHitSlowdown()
		await get_tree().create_timer(0.75, false).timeout
		immunity = false
