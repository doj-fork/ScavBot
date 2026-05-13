extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 520.0
var damage: int = 5
var shooter: Node = null

func setup(newDirection: Vector2, newSpeed: float, newDamage: int, newShooter: Node) -> void:
	direction = newDirection.normalized() if newDirection != Vector2.ZERO else Vector2.RIGHT
	speed = newSpeed
	damage = newDamage
	shooter = newShooter
	rotation = direction.angle()

func _ready() -> void:
	await get_tree().create_timer(2.5, false).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return
	if area == self:
		return

	var parentNode: Node = area.get_parent()
	if parentNode != null and parentNode.has_method("apply_flat_damage"):
		#parentNode.apply_flat_damage(damage, shooter)
		
		#This wasnt working so this is a very temporary fix
		Stats.health -= damage
		
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
