extends Control

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			
			visible = player.item is Ranged
			
			for child in get_children():
				remove_child(child)
				
			for _i in range(player.item.max_bullets - player.item.bullets):
				add_child(preload("res://gui/ammo/empty_bullet.tscn").instance())
			for _i in range(player.item.bullets):
				add_child(preload("res://gui/ammo/bullet.tscn").instance())
