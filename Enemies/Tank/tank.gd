extends CharacterBody2D
class_name Tank

# im sorry for the amount of editable variables in advance but ill explain it along the way
# this is the established speed vairable alongside the detection radius of the enemy
var baseSpeed: float = 80.0 + ceil(Stats.speedMult / 2.0)
var detectionRadius: float = 600.0

#this is the changable values for wandering
var wanderSpeedMultiplier: float = 0.25
var wanderDirectionMinTime: float = 3.0
var wanderDirectionMaxTime: float = 5.0
var health: int = 300 + (Stats.healthMult * 10)

# cram
var separationRadius: float = 130.0
var separationStrength: float = 1.1
var crowdStrafeBias: float = 0.0
var antiCramRetreatDuration: float = 3.0
var antiCramRetreatTimer: float = 0.0
var justEndedAntiCramRetreat: bool = false
var antiCramNeighborThreshold: int = 5

# hit radius
var playerHitSlowdownDuration: float = 1.5
var playerHitSlowdownTimer: float = 0.0
var playerHitSlowdownRadius: float = 120.0
var playerHitSlowdownMultiplier: float = 0.4
var playerHitRetreatDuration: float = 0.25
var playerHitRetreatTimer: float = 0.0
var isPlayerHitRetreating: bool = false

# this is the speed for when the tank actually follows you
var chaseSpeedMultiplier: float = 1.0
var lastMoveDirection: Vector2 = Vector2.RIGHT
var isChasingPlayer: bool = false
var hasPlayedDetectSound: bool = false
var requiresDetectionReset: bool = false
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

var wallStuckTimer: float = 0.0
var wallStuckThreshold: float = 4.0
var wallEscapeTimer: float = 0.0
var wallEscapeDuration: float = 1.5
var wallEscapeDirection: Vector2 = Vector2.ZERO
var _thrashWindowTimer: float = 0.0
var _thrashCount: int = 0
var _lastThrashDir: Vector2 = Vector2.ZERO

var chaseNearObstacleRadius: float = 64.0
var _chargeStartPosition: Vector2 = Vector2.ZERO
var minCrashDistance: float = 50.0

var _chargeExclusions: Array[PhysicsBody2D] = []

@onready var tankSprite: Sprite2D = $Tank
@onready var detectSound: AudioStreamPlayer2D = $DetectSound
@onready var deathSound: AudioStreamPlayer2D = $DeathSound
@onready var chargeSound: AudioStreamPlayer2D = $ChargeSound
@onready var crashSound: AudioStreamPlayer2D = $CrashSound

var animState = "Move"
@onready var animTree = $AnimationTree
@onready var stateMachine = animTree.get("parameters/playback")

func _process(_delta):
	var animDir = velocity.normalized()
	animUpdate(animDir)
	
func animUpdate(dir):
	animTree.set("parameters/Move/blend_position", dir)
	animTree.set("parameters/Hit/blend_position", ((Global.playerPos - global_position).normalized()))
	stateMachine.travel(animState)
	
func hitAnim():
	animState = "Hit"
	await get_tree().create_timer(0.9, false).timeout
	animState = "Move"

# main function
func _ready() -> void:
	self.reparent(get_tree().current_scene)
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
	_updatePlayerHitSlowdown(delta)
	_updatePlayerHitRetreat(delta)
	_updateAntiCramRetreat(delta)

	if _isAntiCramRetreating() or justEndedAntiCramRetreat:
		isChasingPlayer = false
		if chargeState != CHARGE_STATE_CHASE:
			chargeState = CHARGE_STATE_CHASE
			_scheduleNextCharge()
		_updateWanderMovement(playerPosition, delta)
	elif _isPlayerHitRetreating():
		isChasingPlayer = false
		if chargeState != CHARGE_STATE_CHASE:
			chargeState = CHARGE_STATE_CHASE
			_scheduleNextCharge()
		_updatePlayerHitRetreatMovement(playerPosition)
	else:
		_updateChaseState(playerPosition)
		if isChasingPlayer:
			_updateChaseMovement(playerPosition, delta)
		else:
			_updateWanderMovement(playerPosition, delta)

	move_and_slide()
	_applyCollisionResponses()
	_updateWallStuck(delta, playerPosition)
	_updateDirThrash(delta, playerPosition)

# checks for chase
func _updateChaseState(playerPosition: Vector2) -> void:
	if isChasingPlayer:
		return
	if requiresDetectionReset:
		if global_position.distance_to(playerPosition) > detectionRadius:
			requiresDetectionReset = false
		else:
			return
	if global_position.distance_to(playerPosition) <= detectionRadius:
		if _isNearObstacle():
			return
		isChasingPlayer = true
		chargeState = CHARGE_STATE_CHASE
		_scheduleNextCharge()
		if not hasPlayedDetectSound:
			hasPlayedDetectSound = true
			detectSound.play()

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
		_setEnemyCollisionExclusions(false)

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

		var currentSpeed: float = baseSpeed * chaseSpeedMultiplier * _getPlayerHitSlowdownMultiplier()
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
	_setEnemyCollisionExclusions(true)

# starting forward charge 
func _startCharge() -> void:
	chargeState = CHARGE_STATE_CHARGE
	chargeTimer = chargeDuration
	currentChargeSpeed = baseSpeed * chargeStartSpeedMultiplier
	_chargeStartPosition = global_position
	chargeSound.play()

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
	_setEnemyCollisionExclusions(false)

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

func _updateWallStuck(delta: float, playerPosition: Vector2) -> void:
	if isFrozenAfterCrash or _isAntiCramRetreating() or _isPlayerHitRetreating():
		wallStuckTimer = 0.0
		wallEscapeTimer = max(wallEscapeTimer - delta, 0.0)
		return

	if wallEscapeTimer > 0.0:
		wallEscapeTimer -= delta
		if wallEscapeTimer <= 0.0:
			wallEscapeDirection = Vector2.ZERO
		return

	var isNearWall: bool = false
	var collisionCount: int = get_slide_collision_count()
	for i in range(collisionCount):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if _isObstacleCollider(collider) and not _isMeleeCollider(collider):
			isNearWall = true
			break

	if isNearWall and isChasingPlayer and chargeState == CHARGE_STATE_CHASE:
		wallStuckTimer += delta
		if wallStuckTimer >= wallStuckThreshold:
			_triggerWallEscape(playerPosition)
	else:
		wallStuckTimer = max(wallStuckTimer - delta * 2.0, 0.0)

func _triggerWallEscape(playerPosition: Vector2) -> void:
	wallStuckTimer = 0.0
	wallEscapeTimer = wallEscapeDuration
	var directionToPlayer: Vector2 = global_position.direction_to(playerPosition)
	var angleOffsets: Array[float] = [PI * 0.5, -PI * 0.5, PI * 0.55, -PI * 0.55]
	var chosenAngle: float = angleOffsets[randomNumberGenerator.randi() % angleOffsets.size()]
	wallEscapeDirection = directionToPlayer.rotated(chosenAngle).normalized()
	# Interrupt any current chase and pick a new wander direction away from the wall
	isChasingPlayer = false
	wanderDirection = wallEscapeDirection
	wanderDirectionTimer = wallEscapeDuration

func _updateDirThrash(delta: float, playerPosition: Vector2) -> void:
	if isFrozenAfterCrash or wallEscapeTimer > 0.0 or _isAntiCramRetreating() or _isPlayerHitRetreating() or chargeState != CHARGE_STATE_CHASE:
		_thrashCount = 0
		_lastThrashDir = Vector2.ZERO
		_thrashWindowTimer = 0.0
		return
	if _thrashWindowTimer > 0.0:
		_thrashWindowTimer -= delta
		if _thrashWindowTimer <= 0.0:
			_thrashCount = 0
			_lastThrashDir = Vector2.ZERO
	var currentDir: Vector2 = velocity.normalized()
	if currentDir != Vector2.ZERO and _lastThrashDir != Vector2.ZERO:
		if currentDir.dot(_lastThrashDir) < 0.0:
			_thrashWindowTimer = 1.0
			_thrashCount += 1
			_lastThrashDir = currentDir
			if _thrashCount > 4:
				_triggerWallEscape(playerPosition)
				_thrashCount = 0
				_thrashWindowTimer = 0.0
				_lastThrashDir = Vector2.ZERO
			return
	if currentDir != Vector2.ZERO:
		_lastThrashDir = currentDir

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
	# First pass: player collision takes full priority — prevents wall crashes
	# in the same frame from firing the freeze/crash sequence
	for collisionIndex in range(collisionCount):
		var collision: KinematicCollision2D = get_slide_collision(collisionIndex)
		var collider: Object = collision.get_collider()
		if _isPlayerCollider(collider):
			if chargeState == CHARGE_STATE_BACKSTEP or chargeState == CHARGE_STATE_CHARGE:
				_startPlayerCollisionRepath(collision)
			return
	# Second pass: obstacle/wall collisions (only reached if no player was hit)
	for collisionIndex in range(collisionCount):
		var collision: KinematicCollision2D = get_slide_collision(collisionIndex)
		var collider: Object = collision.get_collider()
		if _isObstacleCollider(collider):
			if chargeState == CHARGE_STATE_BACKSTEP or chargeState == CHARGE_STATE_CHARGE:
				_startFreezeAfterCrash()
			elif chargeState == CHARGE_STATE_CHASE and isChasingPlayer:
				if _isCollectibleCollider(collider):
					if randomNumberGenerator.randi() % 2 == 0:
						_startFreezeAfterCrash()
					else:
						_startCollectibleAvoidance(collision)
				else:
					_startFreezeAfterCrash()
			break

# freeze state
func _startFreezeAfterCrash() -> void:
	if chargeState == CHARGE_STATE_CHARGE and global_position.distance_to(_chargeStartPosition) < minCrashDistance:
		_endCharge()
		return
	isFrozenAfterCrash = true
	isChasingPlayer = false
	requiresDetectionReset = true
	freezeTimer = freezeDuration
	velocity = Vector2.ZERO
	chargeState = CHARGE_STATE_CHASE
	if chargeSound.playing:
		chargeSound.stop()
	crashSound.play()
	_updateFrozenTint()
	_setEnemyCollisionExclusions(false)

# updates freeze state
func _updateFreeze(delta: float) -> void:
	freezeTimer -= delta
	velocity = Vector2.ZERO
	if freezeTimer <= 0.0:
		isFrozenAfterCrash = false
		isChasingPlayer = false
		chargeState = CHARGE_STATE_CHASE
		_pickRandomWanderDirection()
		_scheduleNextCharge()
		_updateFrozenTint()

# updates player hit slowdown timer
func _updatePlayerHitSlowdown(delta: float) -> void:
	if playerHitSlowdownTimer > 0.0:
		playerHitSlowdownTimer -= delta

# gets the slowdown multiplier based on player hit slowdown state
func _getPlayerHitSlowdownMultiplier() -> float:
	var playerPosition: Vector2 = Vector2(Global.playerPos)
	var distanceToPlayer: float = global_position.distance_to(playerPosition)
	
	# check if we're within the slowdown radius and moving away from player
	if playerHitSlowdownTimer > 0.0 and distanceToPlayer < playerHitSlowdownRadius:
		var directionToPlayer: Vector2 = global_position.direction_to(playerPosition)
		var movementDirection: Vector2 = velocity.normalized()
		
		# check if moving away from player (dot product < 0)
		if directionToPlayer.dot(movementDirection) < 0.0:
			return playerHitSlowdownMultiplier
	
	return 1.0

# triggers player hit slowdown when player takes damage
func _triggerPlayerHitSlowdown() -> void:
	playerHitSlowdownTimer = playerHitSlowdownDuration

# update player hit retreat timer
func _updatePlayerHitRetreat(delta: float) -> void:
	if playerHitRetreatTimer > 0.0:
		playerHitRetreatTimer -= delta
		if playerHitRetreatTimer <= 0.0:
			isPlayerHitRetreating = false

# get retreat direction away from player
func _getPlayerHitRetreatDirection(playerPosition: Vector2) -> Vector2:
	if isPlayerHitRetreating:
		return (global_position - playerPosition).normalized()
	return Vector2.ZERO

# trigger retreat when player is hit by this enemy
func _triggerPlayerHitRetreat() -> void:
	hitAnim()
	playerHitRetreatTimer = playerHitRetreatDuration
	isPlayerHitRetreating = true
	isChasingPlayer = false
	if chargeState != CHARGE_STATE_CHASE:
		chargeState = CHARGE_STATE_CHASE
		_scheduleNextCharge()
		_setEnemyCollisionExclusions(false)

# check if currently retreating from player hit
func _isPlayerHitRetreating() -> bool:
	return playerHitRetreatTimer > 0.0

# move away from player during retreat
func _updatePlayerHitRetreatMovement(playerPosition: Vector2) -> void:
	var retreatDirection: Vector2 = _getPlayerHitRetreatDirection(playerPosition)
	if retreatDirection == Vector2.ZERO:
		retreatDirection = -lastMoveDirection
	if retreatDirection == Vector2.ZERO:
		retreatDirection = Vector2.RIGHT
	if retreatDirection != Vector2.ZERO:
		lastMoveDirection = retreatDirection
	velocity = retreatDirection * baseSpeed * chaseSpeedMultiplier

func _setEnemyCollisionExclusions(exclude: bool) -> void:
	if exclude:
		_chargeExclusions.clear()
		var enemyNodes: Array[Node] = get_tree().get_nodes_in_group("Enemies")
		for enemyNode in enemyNodes:
			if enemyNode == self or not is_instance_valid(enemyNode):
				continue
			if enemyNode is PhysicsBody2D:
				var body: PhysicsBody2D = enemyNode as PhysicsBody2D
				add_collision_exception_with(body)
				_chargeExclusions.append(body)
	else:
		for body in _chargeExclusions:
			if is_instance_valid(body):
				remove_collision_exception_with(body)
		_chargeExclusions.clear()

func _isCollectibleCollider(collider: Object) -> bool:
	if collider == null or not (collider is StaticBody2D):
		return false
	var parent: Node = (collider as Node).get_parent()
	return parent is CollectibleBase

func _startCollectibleAvoidance(collision: KinematicCollision2D) -> void:
	var normal: Vector2 = collision.get_normal().normalized()
	if normal == Vector2.ZERO:
		normal = -lastMoveDirection.normalized()
	if normal == Vector2.ZERO:
		normal = Vector2.RIGHT
	isChasingPlayer = false
	wanderDirection = normal
	wanderDirectionTimer = randomNumberGenerator.randf_range(0.8, 1.5)

func _isPlayerCollider(collider: Object) -> bool:
	if collider == null:
		return false
	if collider is Node:
		return (collider as Node).is_in_group("Player")
	return false

func _startPlayerCollisionRepath(collision: KinematicCollision2D) -> void:
	var normal: Vector2 = collision.get_normal().normalized()
	if normal == Vector2.ZERO:
		normal = -lastMoveDirection.normalized()
	if normal == Vector2.ZERO:
		normal = Vector2.RIGHT
	if chargeSound.playing:
		chargeSound.stop()
	chargeState = CHARGE_STATE_CHASE
	_scheduleNextCharge()
	_setEnemyCollisionExclusions(false)
	isChasingPlayer = false
	wanderDirection = normal
	wanderDirectionTimer = randomNumberGenerator.randf_range(0.6, 1.2)

func _isNearObstacle() -> bool:
	var spaceState: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = chaseNearObstacleRadius
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, global_position)
	params.collision_mask = 1
	params.exclude = [get_rid()]
	var results: Array[Dictionary] = spaceState.intersect_shape(params)
	for result in results:
		var collider: Object = result.get("collider")
		if collider is StaticBody2D or collider is TileMapLayer:
			return true
	return false

# idk if this works or not but its supposed to check if it collides to the right things
func _isObstacleCollider(collider: Object) -> bool:
	if collider == null:
		return false
	if collider == self:
		return false
	if _isMeleeCollider(collider):
		return false
	if _isPlayerCollider(collider):
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
		_die()

func _die() -> void:
	Stats.tank_kills += 1
	set_physics_process(false)
	tankSprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$EnemyPlayerCollision/CollisionShape2D.set_deferred("disabled", true)
	$BulletCollision/CollisionShape2D.set_deferred("disabled", true)
	deathSound.play()

func _on_death_sound_finished() -> void:
	queue_free()

func _on_area_2d_2_area_entered(_area: Area2D) -> void:
	queue_free()
