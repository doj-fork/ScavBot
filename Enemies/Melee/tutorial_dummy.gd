extends CharacterBody2D

@export var initial_health: int = 9999

signal died

var health: int = 0
var _bob_time: float = 0.0
const BOB_SPEED: float = 1.2
const BOB_AMPLITUDE: float = 60.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

func _ready() -> void:
	health = initial_health

func _physics_process(delta: float) -> void:
	_bob_time += delta
	velocity = Vector2(0.0, sin(_bob_time * BOB_SPEED) * BOB_AMPLITUDE)
	move_and_slide()

func _on_bullet_collision_area_entered(_area: Area2D) -> void:
	var bullet_damage: int = int(Gun.damage)
	health -= bullet_damage
	if health <= 0:
		_die()

func _die() -> void:
	emit_signal("died")
	set_physics_process(false)
	sprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$BulletCollision/CollisionShape2D.set_deferred("disabled", true)
	death_sound.play()

func _on_death_sound_finished() -> void:
	queue_free()
