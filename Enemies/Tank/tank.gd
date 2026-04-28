extends CharacterBody2D
class_name Tank

# im sorry for the amount of editable variables in advance but ill explain it along the way
# this is the established speed vairable alongside the detection radius of the enemy
var baseSpeed: float = 80.0
var detectionRadius: float = 600.0

#this is the changable values for wandering
var wanderSpeedMultiplier: float = 0.25
var wanderDirectionMinTime: float = 3.0
var wanderDirectionMaxTime: float = 5.0
var health: int = 750
var separationRadius: float = 130.0
var separationStrength: float = 1.1
var crowdStrafeBias: float = 0.0
var antiCramRetreatDuration: float = 3.0
var antiCramRetreatTimer: float = 0.0
var justEndedAntiCramRetreat: bool = false
var antiCramNeighborThreshold: int = 5

# this is the speed for when the tank actually follows you
var chaseSpeedMultiplier: float = 1.0
var lastMoveDirection: Vector2 = Vector2.RIGHT
var isChasingPlayer: bool = false
var wanderDirection: Vector2 = Vector2.RIGHT
var wanderDirectionTimer: float = 0.0
var randomNumberGenerator: RandomNumberGenerator = RandomNumberGenerator.new()

# this is for when the tank goes back and charges at you
const CHARGE_STATE_CHASE: int = 0
const CHARGE_STATE_BACKSTEP: int = 1
const CHARGE_STATE_CHARGE: int = 2
var chargeState: int = CHARGE_STATE_CHASE
var chargeTargetPosition: Vector2 = Vector2.ZERO
var chargeDirection: Vector2 = Vector2.RIGHT
var backstepDirection: Vector2 = Vector2.LEFT

# value for how long the charge will happen
var chargeTriggerTimer: float = 0.0
var chargeTriggerMinTime: float = 1.6
var chargeTriggerMaxTime: float = 5.0

# values for when the tank moves backwards to charge at you
var backstepTimer: float = 0.0
var backstepMinDuration: float = 0.2
var backstepMaxDuration: float = 0.45
var backstepSpeedMultiplier: float = 1.5

# the actual values for when the tank charges at you
var chargeTimer: float = 0.0
var chargeDuration: float = 2
var chargeStartSpeedMultiplier: float = 1.5
var chargeMaxSpeedMultiplier: float = 5.0
var chargeAcceleration: float = 900.0
var currentChargeSpeed: float = 0.0
var chargeStopDistance: float = 14.0

# if the tank collides into something
var isFrozenAfterCrash: bool = false
var freezeTimer: float = 0.0
var freezeDuration: float = 5.0
var normalSpriteModulate: Color = Color.WHITE
var frozenSpriteModulate: Color = Color.RED

@onready var tankSprite: Sprite2D = $Tank

# main function
func _ready() -> void:
	add_to_group("Enemies")
	add_to_group("Tank")
	randomNumberGenerator.randomize()
	crowdStrafeBias = randomNumberGenerator.randf_range(-1.0, 1.0)
	_pickRandomWanderDirection()
	_scheduleNextCharge()
	normalSpriteModulate = tankSprite.modulate
	_updateFrozenTint()

# movement function
func _physics_process(delta: float) -> void:
	if isFrozenAfterCrash:
		_updateFreeze(delta)
		move_and_slide()
		return

	var playerPosition: Vector2 = Vector2(Global.playerPos)
	justEndedAntiCramRetreat = false
	_updateAntiCramRetreat(delta)

	if _isAntiCramRetreating() or justEndedAntiCramRetreat:
		isChasingPlayer = false
		if chargeState != CHARGE_STATE_CHASE:
			chargeState = CHARGE_STATE_CHASE
			_scheduleNextCharge()
		_updateWanderMovement(playerPosition, delta)
	else:
		_updateChaseState(playerPosition)
		if isChasingPlayer:
			_updateChaseMovement(playerPosition, delta)
		else:
			_updateWanderMovement(playerPosition, delta)

	move_and_slide()
	_applyCollisionResponses()

# checks for chase
func _updateChaseState(playerPosition: Vector2) -> void:
	if isChasingPlayer:
		return
	if global_position.distance_to(playerPosition) <= detectionRadius:
		isChasingPlayer = true
		chargeState = CHARGE_STATE_CHASE
		_scheduleNextCharge()

func _isAntiCramRetreating() -> bool:
	return antiCramRetreatTimer > 0.0

func _updateAntiCramRetreat(delta: float) -> void:
	if antiCramRetreatTimer > 0.0:
		antiCramRetreatTimer = max(antiCramRetreatTimer - delta, 0.0)
		if antiCramRetreatTimer == 0.0:
			justEndedAntiCramRetreat = true
			isChasingPlayer = false
			chargeState = CHARGE_STATE_CHASE
			_scheduleNextCharge()
		return

	var nearbyEnemyCount: int = _getNearbyEnemyCount()
	if nearbyEnemyCount > antiCramNeighborThreshold:
		antiCramRetreatTimer = antiCramRetreatDuration
		isChasingPlayer = false
		chargeState = CHARGE_STATE_CHASE
		_scheduleNextCharge()

# updates chase
func _updateChaseMovement(playerPosition: Vector2, delta: float) -> void:
	if chargeState == CHARGE_STATE_CHASE:
		chargeTriggerTimer -= delta
		if chargeTriggerTimer <= 0.0:
			_startBackstep(playerPosition)
			return

		var moveDirection: Vector2 = global_position.direction_to(playerPosition)
		moveDirection = _applyEnemySeparation(moveDirection, playerPosition)
		if moveDirection != Vector2.ZERO:
			lastMoveDirection = moveDirection

		var currentSpeed: float = baseSpeed * chaseSpeedMultiplier
		velocity = moveDirection * currentSpeed
		return

	if chargeState == CHARGE_STATE_BACKSTEP:
		backstepTimer -= delta
		if backstepDirection != Vector2.ZERO:
			lastMoveDirection = backstepDirection

		var backstepSpeed: float = baseSpeed * backstepSpeedMultiplier
		velocity = backstepDirection * backstepSpeed

		if backstepTimer <= 0.0:
			_startCharge()
		return

	if chargeState == CHARGE_STATE_CHARGE:
		_updateCharge(delta)
		return

# part of the charge sequence when tank moves backwards (sorry that its really messy)
func _startBackstep(playerPosition: Vector2) -> void:
	chargeTargetPosition = playerPosition

	var pursuitDirection: Vector2 = global_position.direction_to(chargeTargetPosition)
	if pursuitDirection == Vector2.ZERO:
		pursuitDirection = lastMoveDirection
	if pursuitDirection == Vector2.ZERO:
		pursuitDirection = Vector2.RIGHT

	chargeDirection = pursuitDirection.normalized()

	var angleOffset: float = randomNumberGenerator.randf_range(-0.65, 0.65)
	backstepDirection = (-chargeDirection).rotated(angleOffset).normalized()
	if backstepDirection == Vector2.ZERO:
		backstepDirection = -chargeDirection

	backstepTimer = randomNumberGenerator.randf_range(backstepMinDuration, backstepMaxDuration)
	chargeState = CHARGE_STATE_BACKSTEP

# starting forward charge 
func _startCharge() -> void:
	chargeState = CHARGE_STATE_CHARGE
	chargeTimer = chargeDuration
	currentChargeSpeed = baseSpeed * chargeStartSpeedMultiplier

	var refreshedDirection: Vector2 = global_position.direction_to(chargeTargetPosition)
	if refreshedDirection != Vector2.ZERO:
		chargeDirection = refreshedDirection.normalized()

# the forward charge
func _updateCharge(delta: float) -> void:
	chargeTimer -= delta
	currentChargeSpeed = min(currentChargeSpeed + (chargeAcceleration * delta), baseSpeed * chargeMaxSpeedMultiplier)
	velocity = chargeDirection * currentChargeSpeed
	lastMoveDirection = chargeDirection

	var reachedStoredTarget: bool = global_position.distance_to(chargeTargetPosition) <= chargeStopDistance
	if chargeTimer <= 0.0 or reachedStoredTarget:
		_endCharge()

# ends the charge
func _endCharge() -> void:
	chargeState = CHARGE_STATE_CHASE
	_scheduleNextCharge()

# the random movement before an enemy sees you
func _updateWanderMovement(playerPosition: Vector2, delta: float) -> void:
	wanderDirectionTimer -= delta
	if wanderDirectionTimer <= 0.0:
		_pickRandomWanderDirection()

	var moveDirection: Vector2 = _applyEnemySeparation(wanderDirection, playerPosition)
	if moveDirection != Vector2.ZERO:
		lastMoveDirection = moveDirection

	var currentSpeed: float = baseSpeed * wanderSpeedMultiplier
	velocity = moveDirection * currentSpeed

# randomized direction for wander
func _pickRandomWanderDirection() -> void:
	var randomAngle: float = randomNumberGenerator.randf_range(0.0, TAU)
	wanderDirection = Vector2.RIGHT.rotated(randomAngle).normalized()
	wanderDirectionTimer = randomNumberGenerator.randf_range(wanderDirectionMinTime, wanderDirectionMaxTime)

# separation between enemies 
func _applyEnemySeparation(baseDirection: Vector2, playerPosition: Vector2) -> Vector2:
	if not _isAntiCramRetreating():
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
	
# anti cram
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

# timer for charge when enemy locks onto you
func _scheduleNextCharge() -> void:
	chargeTriggerTimer = randomNumberGenerator.randf_range(chargeTriggerMinTime, chargeTriggerMaxTime)

# haha tank went red
func _updateFrozenTint() -> void:
	if isFrozenAfterCrash:
		tankSprite.modulate = frozenSpriteModulate
	else:
		tankSprite.modulate = normalSpriteModulate

# enemy collision check
func _applyCollisionResponses() -> void:
	var collisionCount: int = get_slide_collision_count()
	for collisionIndex in range(collisionCount):
		var collision: KinematicCollision2D = get_slide_collision(collisionIndex)
		var collider: Object = collision.get_collider()
		if _isObstacleCollider(collider):
			if chargeState == CHARGE_STATE_BACKSTEP or chargeState == CHARGE_STATE_CHARGE:
				_startFreezeAfterCrash()
			break

# freeze state
func _startFreezeAfterCrash() -> void:
	isFrozenAfterCrash = true
	freezeTimer = freezeDuration
	velocity = Vector2.ZERO
	chargeState = CHARGE_STATE_CHASE
	_updateFrozenTint()

# updates freeze state
func _updateFreeze(delta: float) -> void:
	freezeTimer -= delta
	velocity = Vector2.ZERO
	if freezeTimer <= 0.0:
		isFrozenAfterCrash = false
		_scheduleNextCharge()
		_updateFrozenTint()

# idk if this works or not but its supposed to check if it collides to the right things
func _isObstacleCollider(collider: Object) -> bool:
	if collider == null:
		return false
	if collider == self:
		return false
	if _isMeleeCollider(collider):
		return false
	if collider is TileMapLayer:
		return true
	if collider is CollisionObject2D:
		return true
	return false

# ditto, but for melee enemies. will rewrite this when we get other enemies
func _isMeleeCollider(collider: Object) -> bool:
	if collider is MeleeEnemy:
		return true
	if collider is Node:
		var colliderNode: Node = collider as Node
		if colliderNode.is_in_group("Melee"):
			return true
		if colliderNode.name.findn("Melee") != -1:
			return true
	return false

func _on_bullet_collision_area_entered(_area: Area2D) -> void:
	var bulletDamage: int = int(Gun.damage)
	health -= bulletDamage
	if health <= 0:
		queue_free()

func _on_area_2d_2_area_entered(_area: Area2D) -> void:
	queue_free()
