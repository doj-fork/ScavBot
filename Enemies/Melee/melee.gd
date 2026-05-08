extends CharacterBody2D
class_name MeleeEnemy

var baseSpeed: float = 180.0 + ceil(Stats.speedMult / 2.0)
var obstacleSlowMultiplier: float = 0.85
var slowRecoveryRate: float = 3.5
var detourDistance: float = 140.0
var detourDuration: float = 0.75
var detectionRadius: float = 400.0
var wanderSpeedMultiplier: float = 0.5
var wanderDirectionMinTime: float = 0.5
var wanderDirectionMaxTime: float = 2.5
var health: int = 100 + (Stats.healthMult * 3)
var separationRadius: float = 110.0
var separationStrength: float = 1.25
var crowdStrafeBias: float = 0.0
var antiCramRetreatDuration: float = 3.0
var antiCramRetreatTimer: float = 0.0
var justEndedAntiCramRetreat: bool = false
var antiCramNeighborThreshold: int = 5

var chaseSpeedMultiplier: float = 1.0
var detourTarget: Vector2 = Vector2.ZERO
var detourTimer: float = 0.0
var hasDetourTarget: bool = false
var lastMoveDirection: Vector2 = Vector2.RIGHT
var isChasingPlayer: bool = false
var wanderDirection: Vector2 = Vector2.RIGHT
var wanderDirectionTimer: float = 0.0
var randomNumberGenerator: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("Enemies")
	add_to_group("Melee")
	randomNumberGenerator.randomize()
	crowdStrafeBias = randomNumberGenerator.randf_range(-1.0, 1.0)
	_pickRandomWanderDirection()

# main enemy movement from your thing
func _physics_process(delta: float) -> void:
	var playerPosition: Vector2 = Vector2(Global.playerPos)
	justEndedAntiCramRetreat = false
	_updateAntiCramRetreat(delta)

	if _isAntiCramRetreating() or justEndedAntiCramRetreat:
		isChasingPlayer = false
		_updateWanderMovement(playerPosition, delta)
	else:
		_updateChaseState(playerPosition)
		if isChasingPlayer:
			_updateChaseMovement(playerPosition, delta)
		else:
			_updateWanderMovement(playerPosition, delta)

	move_and_slide()
	_applyCollisionResponses(playerPosition)
	_recoverChaseSpeed(delta)

func _updateChaseState(playerPosition: Vector2) -> void:
	if isChasingPlayer:
		return
	if global_position.distance_to(playerPosition) <= detectionRadius:
		isChasingPlayer = true
		hasDetourTarget = false

func _updateAntiCramRetreat(delta: float) -> void:
	if antiCramRetreatTimer > 0.0:
		antiCramRetreatTimer = max(antiCramRetreatTimer - delta, 0.0)
		if antiCramRetreatTimer <= 0.0:
			isChasingPlayer = false
			hasDetourTarget = false
			justEndedAntiCramRetreat = true
			_pickRandomWanderDirection()
		return

	var nearbyEnemyCount: int = _getNearbyEnemyCount()
	if nearbyEnemyCount > antiCramNeighborThreshold:
		antiCramRetreatTimer = antiCramRetreatDuration
		isChasingPlayer = false
		hasDetourTarget = false

func _isAntiCramRetreating() -> bool:
	return antiCramRetreatTimer > 0.0

func _updateChaseMovement(playerPosition: Vector2, delta: float) -> void:
	var activeTarget: Vector2 = playerPosition

	if hasDetourTarget:
		detourTimer -= delta
		var reachedDetour: bool = global_position.distance_to(detourTarget) <= 12.0
		if reachedDetour or detourTimer <= 0.0:
			hasDetourTarget = false
		else:
			activeTarget = detourTarget

	var moveDirection: Vector2 = global_position.direction_to(activeTarget)
	moveDirection = _applyEnemySeparation(moveDirection, playerPosition)
	if moveDirection != Vector2.ZERO:
		lastMoveDirection = moveDirection

	var currentSpeed: float = baseSpeed * chaseSpeedMultiplier
	velocity = moveDirection * currentSpeed

# enemy randomly moves around until you enter its radius
func _updateWanderMovement(playerPosition: Vector2, delta: float) -> void:
	wanderDirectionTimer -= delta
	if wanderDirectionTimer <= 0.0:
		_pickRandomWanderDirection()

	var moveDirection: Vector2 = _applyEnemySeparation(wanderDirection, playerPosition)
	if moveDirection != Vector2.ZERO:
		lastMoveDirection = moveDirection

	var currentSpeed: float = baseSpeed * wanderSpeedMultiplier * chaseSpeedMultiplier
	velocity = moveDirection * currentSpeed

# ^ditto to previous comment
func _pickRandomWanderDirection() -> void:
	var randomAngle: float = randomNumberGenerator.randf_range(0.0, TAU)
	wanderDirection = Vector2.RIGHT.rotated(randomAngle).normalized()
	wanderDirectionTimer = randomNumberGenerator.randf_range(wanderDirectionMinTime, wanderDirectionMaxTime)

func _applyEnemySeparation(baseDirection: Vector2, playerPosition: Vector2) -> Vector2:
	var forceRetreat: bool = _isAntiCramRetreating()
	if not forceRetreat:
		return baseDirection

	var crowdPressure: float = _getEnemyCrowdPressure()
	var awayFromPlayer: Vector2 = playerPosition.direction_to(global_position)
	if awayFromPlayer == Vector2.ZERO:
		awayFromPlayer = -baseDirection
	if awayFromPlayer == Vector2.ZERO:
		awayFromPlayer = Vector2.RIGHT

	var tangentFromPlayer: Vector2 = Vector2(-awayFromPlayer.y, awayFromPlayer.x).normalized()
	var retreatDirection: Vector2 = (awayFromPlayer + (tangentFromPlayer * crowdStrafeBias * 0.45)).normalized()
	var retreatPressure: float = max(crowdPressure, 1.0)
	var retreatWeight: float = clamp(retreatPressure * separationStrength, 0.0, 1.0)
	var combinedDirection: Vector2 = ((baseDirection * (1.0 - retreatWeight)) + (retreatDirection * retreatWeight)).normalized()

	if combinedDirection == Vector2.ZERO:
		return retreatDirection
	return combinedDirection

func _getNearbyEnemyCount() -> int:
	var nearbyCount: int = 0
	var enemyNodes: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	for enemyNode: Node in enemyNodes:
		if enemyNode == self:
			continue
		if not (enemyNode is CharacterBody2D):
			continue
		var enemyBody: CharacterBody2D = enemyNode as CharacterBody2D
		if global_position.distance_to(enemyBody.global_position) > separationRadius:
			continue
		nearbyCount += 1
	return nearbyCount

func _getEnemyCrowdPressure() -> float:
	var pressureTotal: float = 0.0
	var nearbyEnemies: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	for enemyNode: Node in nearbyEnemies:
		if enemyNode == self:
			continue
		if not enemyNode is CharacterBody2D:
			continue

		var enemyBody: CharacterBody2D = enemyNode as CharacterBody2D
		var distanceToEnemy: float = global_position.distance_to(enemyBody.global_position)
		if distanceToEnemy <= 0.001 or distanceToEnemy > separationRadius:
			continue

		pressureTotal += 1.0 - (distanceToEnemy / separationRadius)

	return clamp(pressureTotal, 0.0, 1.0)

func _applyCollisionResponses(playerPosition: Vector2) -> void:
	var collisionCount: int = get_slide_collision_count()
	for collisionIndex in range(collisionCount):
		var collision: KinematicCollision2D = get_slide_collision(collisionIndex)
		var collider: Object = collision.get_collider()
		if _isObstacleCollider(collider):
			_applyObstacleSlowdownAndDetour(collision, playerPosition)
			break

# this slows down the enemy when they collide with something
func _applyObstacleSlowdownAndDetour(collision: KinematicCollision2D, playerPosition: Vector2) -> void:
	chaseSpeedMultiplier = min(chaseSpeedMultiplier, obstacleSlowMultiplier)

	var collisionNormal: Vector2 = collision.get_normal().normalized()
	if collisionNormal == Vector2.ZERO:
		collisionNormal = -lastMoveDirection.normalized()

	var movementIntentDirection: Vector2 = lastMoveDirection
	if isChasingPlayer:
		movementIntentDirection = global_position.direction_to(playerPosition)
	if movementIntentDirection == Vector2.ZERO:
		movementIntentDirection = lastMoveDirection

	var tangentA: Vector2 = Vector2(-collisionNormal.y, collisionNormal.x).normalized()
	var tangentB: Vector2 = -tangentA
	var scoreA: float = tangentA.dot(movementIntentDirection)
	var scoreB: float = tangentB.dot(movementIntentDirection)
	var chosenTangent: Vector2 = tangentA if scoreA >= scoreB else tangentB

	detourTarget = global_position + (chosenTangent * detourDistance) + (collisionNormal * 24.0)
	hasDetourTarget = true
	detourTimer = detourDuration

func _recoverChaseSpeed(delta: float) -> void:
	chaseSpeedMultiplier = move_toward(chaseSpeedMultiplier, 1.0, slowRecoveryRate * delta)

func _isObstacleCollider(collider: Object) -> bool:
	if collider == null:
		return false
	if collider == self:
		return false
	if collider is TileMapLayer:
		return true
	if collider is CollisionObject2D:
		return true
	return false

# add geometric slowdown function here

func _on_area_2d_2_area_entered(_area: Area2D) -> void:
	queue_free()

func _on_bullet_collision_area_entered(_area: Area2D) -> void:
	var bulletDamage: int = int(Gun.damage)
	health -= bulletDamage
	if health <= 0:
		queue_free()
