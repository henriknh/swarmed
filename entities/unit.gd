extends Entity

class_name Unit

export(int) var max_health = 1
onready var health = max_health setget set_health

func set_health(_health):
	health = _health
	if health <= 0:
		queue_free()
