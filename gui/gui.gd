extends Control 

onready var health: ProgressBar = $BottomLeft/VBoxContainer/Health
onready var energy: ProgressBar = $BottomLeft/VBoxContainer/Energy
onready var ammo: ProgressBar = $BottomRight/VBoxContainer/Ammo

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			
			health.max_value = player.max_health
			health.value = player.health
			
			energy.max_value = player.max_energy
			energy.value = player.energy
			
			
			ammo.visible = player.item is Ranged
			if ammo.visible:
				ammo.max_value = player.item.max_bullets
				ammo.value = player.item.bullets
