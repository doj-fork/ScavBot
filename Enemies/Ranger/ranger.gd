extends CharacterBody2D
class_name RangerEnemy

const RANGER_BULLET_SCENE: PackedScene = preload("res://Enemies/ranger/ranger_bullet.tscn")

var baseSpeed: float = 150.0 + ceil(Stats.speedMult / 2.0)
var detectionRadius: float = 700.0
var wanderSpeedMultiplier: float = 0.35
var wanderDirectionMinTime: float = 0.75
var wanderDirectionMaxTime: float = 2.5
var health: int = 50 + (Stats.healthMult * 3)

var preferredMinDistance: float = 280.0
var preferredMaxDistance: float = 430.0
var emergencyRetreatDistance: float = 170.0
var strafeBias: float = 1.0

var separationRadius: float = 120.0
var separationStrength: float = 1.15

var shootCooldown: float = 2.5
var shootTimer: float = 0.0
var projectileSpeed: float = 520.0
var projectileDamage: int = 5

var isChasingPlayer: bool = false
var hasPlayedDetectSound: bool = false

@onready var detectSound: AudioStreamPlayer2D = $DetectSound
@onready var deathSound: AudioStreamPlayer2D = $DeathSound
@onready var shootSound: AudioStreamPlayer2D = $ShootSound

var wanderDirection: Vector2 = Vector2.RIGHT
var wanderDirectionTimer: float = 0.0
var randomNumberGenerator: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("Enemies")
	add_to_group("Ranger")
	randomNumberGenerator.randomize()
	strafeBias = -1.0 if randomNumberGenerator.randi() % 2 == 0 else 1.0
	_pickRandomWanderDirection()

func _physics_process(delta: float) -> void:
	var playerPosition: Vector2 = Vector2(Global.playerPos)
	shootTimer = max(shootTimer - delta, 0.0)
	_updateChaseState(playerPosition)

	if isChasingPlayer:
		_updateKiteMovement(playerPosition)
		_tryShoot(playerPosition)
	else:
		_updateWanderMovement(delta)

	move_and_slide()

func _updateChaseState(playerPosition: Vector2) -> void:
	if isChasingPlayer:
		if global_position.distance_to(playerPosition) > detectionRadius * 1.2:
			isChasingPlayer = false
		return

	if global_position.distance_to(playerPosition) <= detectionRadius:
		isChasingPlayer = true
		if not hasPlayedDetectSound:
			hasPlayedDetectSound = true
			detectSound.play()

func _updateKiteMovement(playerPosition: Vector2) -> void:
	var distanceToPlayer: float = global_position.distance_to(playerPosition)
	var directionToPlayer: Vector2 = global_position.direction_to(playerPosition)
	var desiredDirection: Vector2 = Vector2.ZERO

	if distanceToPlayer < emergencyRetreatDistance:
		desiredDirection = -directionToPlayer
	elif distanceToPlayer < preferredMinDistance:
		desiredDirection = (-directionToPlayer + (_getStrafeDirection(directionToPlayer) * 0.35)).normalized()
	elif distanceToPlayer > preferredMaxDistance:
		desiredDirection = directionToPlayer
	else:
		desiredDirection = _getStrafeDirection(directionToPlayer)

	desiredDirection = _applyEnemySeparation(desiredDirection)
	if desiredDirection == Vector2.ZERO:
		desiredDirection = -directionToPlayer if distanceToPlayer < preferredMinDistance else directionToPlayer

	velocity = desiredDirection * baseSpeed

func _updateWanderMovement(delta: float) -> void:
	wanderDirectionTimer -= delta
	if wanderDirectionTimer <= 0.0:
		_pickRandomWanderDirection()

	var moveDirection: Vector2 = _applyEnemySeparation(wanderDirection)
	if moveDirection == Vector2.ZERO:
		moveDirection = wanderDirection

	velocity = moveDirection * baseSpeed * wanderSpeedMultiplier

func _pickRandomWanderDirection() -> void:
	var randomAngle: float = randomNumberGenerator.randf_range(0.0, TAU)
	wanderDirection = Vector2.RIGHT.rotated(randomAngle).normalized()
	wanderDirectionTimer = randomNumberGenerator.randf_range(wanderDirectionMinTime, wanderDirectionMaxTime)

func _getStrafeDirection(directionToPlayer: Vector2) -> Vector2:
	var tangent: Vector2 = Vector2(-directionToPlayer.y, directionToPlayer.x).normalized()
	return tangent * strafeBias

func _applyEnemySeparation(baseDirection: Vector2) -> Vector2:
	var awayVector: Vector2 = Vector2.ZERO
	var enemyNodes: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	for enemyNode: Node in enemyNodes:
		if enemyNode == self:
			continue
		if not (enemyNode is CharacterBody2D):
			continue
		var enemyBody: CharacterBody2D = enemyNode as CharacterBody2D
		var toEnemy: Vector2 = enemyBody.global_position - global_position
		var distance: float = toEnemy.length()
		if distance <= 0.001 or distance > separationRadius:
			continue

		awayVector += (-toEnemy.normalized()) * (1.0 - (distance / separationRadius))

	if awayVector == Vector2.ZERO:
		return baseDirection.normalized()

	var weight: float = clamp(awayVector.length() * separationStrength, 0.0, 1.0)
	var combined: Vector2 = ((baseDirection.normalized() * (1.0 - weight)) + (awayVector.normalized() * weight)).normalized()
	if combined == Vector2.ZERO:
		return awayVector.normalized()
	return combined

func _tryShoot(playerPosition: Vector2) -> void:
	if shootTimer > 0.0:
		return
	if global_position.distance_to(playerPosition) > detectionRadius:
		return

	var bulletDirection: Vector2 = global_position.direction_to(playerPosition)
	if bulletDirection == Vector2.ZERO:
		return

	var bullet: Area2D = RANGER_BULLET_SCENE.instantiate() as Area2D
	if bullet == null:
		return

	bullet.global_position = global_position
	if bullet.has_method("setup"):
		bullet.setup(bulletDirection, projectileSpeed, projectileDamage, self)

	get_tree().current_scene.call_deferred("add_child", bullet)
	shootSound.play()
	shootTimer = shootCooldown

func _on_bullet_collision_area_entered(_area: Area2D) -> void:
	var bulletDamage: int = int(Gun.damage)
	health -= bulletDamage
	if health <= 0:
		_die()

func _die() -> void:
	set_physics_process(false)
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$EnemyPlayerCollision/CollisionShape2D.set_deferred("disabled", true)
	$BulletCollision/CollisionShape2D.set_deferred("disabled", true)
	deathSound.play()

func _on_death_sound_finished() -> void:
	queue_free()

func _on_area_2d_2_area_entered(_area: Area2D) -> void:
	queue_free()
