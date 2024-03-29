extends Node2D

export(int) var speed = 250

var projectile_spread = 10

func _ready():
	rotation_degrees += Random.randf() * projectile_spread - projectile_spread / 2

func _physics_process(delta):
	translate(Vector2(1, 0).rotated(rotation) * speed * delta)

func on_collide(body):
	if not is_queued_for_deletion() and body is Entity:
		body.health -= 1
	queue_free()
