extends Enemy

var enemies = []

func _ready():
	._ready()
	$Line2D.visible = OS.is_debug_build()
	
func on_attack(body):
	for enemy in enemies:
		enemy.health -= 1
	queue_free()

func on_enemy_entered(body):
	if not body in enemies:
		enemies.append(body)

func on_enemy_exited(body):
	enemies.erase(body)


