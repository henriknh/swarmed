extends Node2D

export(int) var speed = 100

var bullet_spread = 10

func _ready():
	rotation_degrees += Random.randf() * bullet_spread - bullet_spread / 2
	#var mouse_position = get_viewport().get_mouse_position() - get_viewport().size / 2
	#look_at(mouse_position - global_position)
	pass

func _physics_process(delta):
	translate(Vector2(1, 0).rotated(rotation) * speed * delta)

func on_collide(body):
	if body is Entity:
		body.health -= 1
	
	queue_free()
