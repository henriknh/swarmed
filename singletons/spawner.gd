extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var spawn_timer = Timer.new()
var floors: TileMap
var floors_cells: Array
var walls: TileMap
var props: TileMap

var i = 0

# Called when the node enters the scene tree for the first time.
func init():
	floors = get_node("/root/Game/Navigation2D/Floor")
	walls = get_node("/root/Game/Navigation2D/Walls")
	props = get_node("/root/Game/Navigation2D/Props")
	
	floors_cells = floors.get_used_cells()
	floors_cells.shuffle()
	
	if get_tree().is_network_server():
		for _i in range(10):
			create_goo()
			
	
	spawn_timer.autostart = true
	spawn_timer.wait_time = Random.randf() * 2 + 1
	spawn_timer.connect("timeout", self, "on_create_goo")
	get_node("/root/Game").add_child(spawn_timer)

func on_create_goo():
	spawn_timer.stop()
	spawn_timer.wait_time = Random.randf() * 2 + 1
	create_goo()
	spawn_timer.start()
	
func create_goo():
	i += 1
	var new_goo = preload("res://entities/enemies/goo/goo.tscn").instance()
	new_goo.name = "%d_%d" % [get_tree().get_network_unique_id(), i]
	new_goo.position = get_valid_position()
	print(new_goo.position)
	new_goo.set_network_master(get_tree().get_network_unique_id())
	get_node("/root/Game").add_child(new_goo)
	

func get_valid_position():
	var position = Vector2.ZERO
	var is_valid = false
	
	while not is_valid:
		position = floors_cells[Random.randi() % floors_cells.size()] * floors.cell_size
		var too_close_to_player = false
		for player in get_tree().get_nodes_in_group("Player"):
			if position.distance_to(player.global_position) <= 100:
				too_close_to_player = true
				break
		
		if not too_close_to_player:
			
			var not_wall = walls.get_cellv(position) == TileMap.INVALID_CELL
			var not_prop = props.get_cellv(position) == TileMap.INVALID_CELL
			if not_wall and not_prop:
				return position
