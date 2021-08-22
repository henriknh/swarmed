extends Control

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			for i in range(get_child_count()):
				var item = player.get_node("Items").get_child(i)
				var node = get_child(i)
				
				var node_background: TextureRect = node.get_node_or_null("Icon/Background")
				node_background.self_modulate = Color(1,1,1, 1 if item == player.get_node("Items").item else 0.5)
				var node_icon: TextureRect = node.get_node_or_null("Icon/Icon")
				node_icon.texture = item.icon
				
				var progress = 0
				if item.equip_timer.time_left > 0:
					progress = (item.equip_timer.time_left / item.equip_time) * 100
				var cooldown: TextureProgress = node.get_node_or_null("Icon/Cooldown")
				cooldown.value = progress
