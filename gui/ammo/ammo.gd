extends Control

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			var item = player.get_node("Items").item
			
			visible = item is Ranged
			
			for child in get_children():
				remove_child(child)
				
			for _i in range(item.max_bullets - item.bullets):
				add_child(preload("res://gui/ammo/empty_bullet.tscn").instance())
			for _i in range(item.bullets):
				add_child(preload("res://gui/ammo/bullet.tscn").instance())
