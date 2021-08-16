extends Control

onready var container: HBoxContainer = $Container
onready var value: HBoxContainer = $Value

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			
			visible = player.armor > 0
			
			value.rect_size.x = player.armor * 3
			container.rect_size.x = player.armor * 3 + 1 
