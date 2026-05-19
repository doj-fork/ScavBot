extends CharacterBody2D

@onready var animator = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var animTree = $AnimationTree
@onready var stateMachine = animTree.get("parameters/playback")
@onready var walkSFX: AudioStreamPlayer2D = $walkSFX

var immunity: bool = false

var inputDir: Vector2 = Vector2(0, 0)
var animDir: Vector2 = Vector2(0, 0)

var animState = "Base"
var animSubState = "Idle"

const WALK_SOUNDS: Array[String] = [
	"res://Assets/SFX/Player/walk1.wav",
	"res://Assets/SFX/Player/walk2.wav",
	"res://Assets/SFX/Player/walk3.wav",
	"res://Assets/SFX/Player/walk4.wav",
	"res://Assets/SFX/Player/walk5.wav"
]
const WALK_SOUND_INTERVAL: float = 1.5

var walkSoundTimer: float = 0.0
var isWalking: bool = false

var lingerDamageRadius: float = 60.0
var lingerDamageThreshold: float = 0.4
var lingerTimers: Dictionary = {}
	
func _ready():
	awaitCollect()
	awaitCharge()
	
func _process(delta):
	animUpdate()
	Global.playerPos = global_position
	inputDir = (Vector2(Input.get_action_strength("Right") - Input.get_action_strength("Left"), Input.get_action_strength("Down") - Input.get_action_strength("Up"))).normalized()
	velocity = inputDir * Stats.speed
	if inputDir != Vector2(0, 0):
		animDir = inputDir
	if Global.cannotCraftCollecting:
		velocity = Vector2.ZERO
		if walkSFX.playing:
			walkSFX.stop()
		isWalking = false
	else:
		play_walk_sound()
	if Global.canMove == 0:
		move_and_slide()
	
	_checkEnemyLingerProximity(delta)
	if Stats.health < 1:
		Global.dead = true
		get_tree().change_scene_to_file.call_deferred("res://Screens/death.tscn")

func awaitCollect():
	await Signals.collecting
	animState = "Special"
	animSubState = "Collect"
	await get_tree().create_timer(1, false).timeout
	animState = "Base"
	awaitCollect()
	
func awaitCharge():
	await Signals.charge
	animState = "Special"
	animSubState = "Charge"
	await get_tree().create_timer(1, false).timeout
	animState = "Base"
	awaitCharge()
	
func animUpdate():
	if animState == "Base":
		updateTexture("Base")
		animTree.set("parameters/Base/blend_position", animDir)
		if velocity == Vector2(0, 0):
			animSubState = "Idle"
		else:
			animSubState = "Move"
		stateMachine.travel("Base")
	else:
		updateTexture("Special")
		stateMachine.travel("Special")
		if animSubState == "Charge":
			animTree.set("parameters/Base/blend_position", Vector2(1, 0))
		elif animSubState == "Collect":
			animTree.set("parameters/Base/blend_position", Vector2(-1, 0))
		
		
func updateTexture(arg):
	if arg == "Base" and Gun.type != "Null":
		if animSubState == "Idle":
			sprite.texture = load("res://Player/Assets/Idle" + Gun.type + ".png")
		else:
			sprite.texture = load("res://Player/Assets/Move" + Gun.type + ".png")
	elif arg == "Base" and Gun.type == "Null":
		if animSubState == "Idle":
			sprite.texture = load("res://Player/Assets/IdleEmpty.png")
		else:
			sprite.texture = load("res://Player/Assets/MoveEmpty.png")
	elif arg == "Special":
		pass

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

# solution to enemy linger issue
func _checkEnemyLingerProximity(delta: float) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closeEnemies: Array = []
	for enemy in enemies:
		if not is_instance_valid(enemy) or not (enemy is CharacterBody2D):
			continue
		var dist: float = global_position.distance_to((enemy as CharacterBody2D).global_position)
		if dist < lingerDamageRadius:
			closeEnemies.append(enemy)
			if not immunity:
				lingerTimers[enemy] = lingerTimers.get(enemy, 0.0) + delta
				if lingerTimers[enemy] >= lingerDamageThreshold:
					lingerTimers.erase(enemy)
					_applyLingerDamage(enemy)
		else:
			lingerTimers.erase(enemy)
	for key in lingerTimers.keys().duplicate():
		if not is_instance_valid(key) or not closeEnemies.has(key):
			lingerTimers.erase(key)

func _applyLingerDamage(enemy: Node) -> void:
	immunity = true
	Stats.health -= 5 + (3 * Stats.damageMult)
	if enemy.has_method("_triggerPlayerHitRetreat"):
		enemy._triggerPlayerHitRetreat()
	if enemy.has_method("_triggerPlayerHitSlowdown"):
		enemy._triggerPlayerHitSlowdown()
	await get_tree().create_timer(0.75, false).timeout
	immunity = false

func apply_flat_damage(amount: int, enemy: Node = null) -> void:
	if immunity:
		return

	immunity = true
	Stats.health -= amount
	if enemy != null and enemy.has_method("_triggerPlayerHitRetreat"):
		enemy._triggerPlayerHitRetreat()
	if enemy != null and enemy.has_method("_triggerPlayerHitSlowdown"):
		enemy._triggerPlayerHitSlowdown()
	await get_tree().create_timer(0.75, false).timeout
	immunity = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if immunity == false:
		immunity = true
		Stats.health -= 5 + (3 * Stats.damageMult)
		var enemy: Node = area.get_parent()
		if enemy.has_method("_triggerPlayerHitRetreat"):
			enemy._triggerPlayerHitRetreat()
		if enemy.has_method("_triggerPlayerHitSlowdown"):
			enemy._triggerPlayerHitSlowdown()
		await get_tree().create_timer(0.75, false).timeout
		immunity = false
