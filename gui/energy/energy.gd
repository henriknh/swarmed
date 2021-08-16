extends Control

onready var background: TextureRect = $Background
onready var energy_slot: HBoxContainer = $Container/EnergySlot
onready var value: HBoxContainer = $Value

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			
			for child in energy_slot.get_children():
				energy_slot.remove_child(child)
				
			for i in range(2, player.max_energy):
				energy_slot.add_child(preload("res://gui/energy/energy_chunk.tscn").instance())
			
			value.visible = player.energy > 0
			var separators = player.energy - 1 if player.energy > 1 else 0
			value.rect_size.x = player.energy * 3 + separators
			
			var max_separators = player.max_energy - 1 if player.max_energy > 1 else 0
			background.rect_size.x = player.max_energy * 3 + max_separators
