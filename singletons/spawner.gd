extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var floors: TileMap
var floors_cells: Array
var walls: TileMap
var props: TileMap


# Called when the node enters the scene tree for the first time.
func init():
	floors = get_node("/root/Game/Navigation2D/Floor")
	walls = get_node("/root/Game/Navigation2D/Walls")
	props = get_node("/root/Game/Navigation2D/Props")
	
	floors_cells = floors.get_used_cells()
	floors_cells.shuffle()
	
	
	if get_tree().is_network_server():
		for i in range(10):
			var new_goo = preload("res://entities/enemies/goo/goo.tscn").instance()
			new_goo.name = "%d_%d" % [get_tree().get_network_unique_id(), i]
			new_goo.position = get_valid_position()
			new_goo.set_network_master(get_tree().get_network_unique_id())
			add_child(new_goo)

func get_valid_position():
	var position = Vector2.ZERO
	var is_valid = false
	
	while not is_valid:
		position = floors_cells[Random.randi() % floors_cells.size()] * floors.cell_size
		var too_close_to_player = false
		for player in get_tree().get_nodes_in_group("Player"):
			if position.distance_to(player.global_position) <= 30:
				too_close_to_player = true
				break
		
		if not too_close_to_player:
			
			var not_wall = walls.get_cellv(position) == TileMap.INVALID_CELL
			var not_prop = props.get_cellv(position) == TileMap.INVALID_CELL
			if not_wall and not_prop :
				return position
