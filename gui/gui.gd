extends Control 

onready var armor: Control = $TopLeft/VBoxContainer/HBoxContainer/Armor

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			armor.rect_position.x = player.max_health * 3 + 2
