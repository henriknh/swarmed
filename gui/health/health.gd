extends Control

onready var container: HBoxContainer = $Container
onready var background: TextureRect = $Background
onready var right: TextureRect = $Container/Right
onready var separator: TextureRect = $Container/Separator
onready var value: HBoxContainer = $Value

func _physics_process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		if int(player.name) == get_tree().get_network_unique_id():
			
			right.visible = player.armor == 0
			separator.visible = player.armor > 0
			
			value.visible = player.health > 0
			value.rect_size.x = player.health * 3
			
			background.rect_size.x = player.max_health * 3
			
			container.rect_size.x = player.max_health * 3 + 2
