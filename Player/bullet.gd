extends CharacterBody2D

var life = true
var direction

func _ready():
	determineVelocity()
	awaitDeath()
	
func _process(_delta):
	if life == true:
		move_and_slide()

func determineVelocity():
	direction = (get_global_mouse_position() - Global.playerPos).normalized()
	var destinationAngle = 0
	destinationAngle = rad_to_deg(direction.angle())
	destinationAngle += randf_range(0, Gun.precision)
	if destinationAngle < 0:
		destinationAngle += 360
	if destinationAngle > 360:
		destinationAngle -= 360
	if destinationAngle > 180:
		destinationAngle -= 360
	velocity = (Vector2.from_angle(deg_to_rad(destinationAngle))).normalized() * Gun.speed
	
func awaitDeath():
	await get_tree().create_timer(0.8, false).timeout
	if life == true:
		bulletDeath()
		
func bulletDeath():
	queue_free.call_deferred()

func _on_enemy_mask_area_entered(_area: Area2D) -> void:
	bulletDeath()
