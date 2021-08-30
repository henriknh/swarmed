extends Enemy

var enemies = []
	
func on_attack(body):
	for enemy in enemies:
		enemy.health -= 1

func on_enemy_entered(body):
	if not body in enemies:
		enemies.append(body)

func on_enemy_exited(body):
	enemies.erase(body)


