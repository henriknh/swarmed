extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var spawn_timer = Timer.new()
var walkable: TileMap
var floors: TileMap
var walkable_cells: Array
var walls: TileMap
var props: TileMap

var i = 0

# Called when the node enters the scene tree for the first time.
func init():
	walkable = get_node("/root/Game/Navigation2D/Walkable")
	floors = get_node("/root/Game/Floor")
	walls = get_node("/root/Game/Walls")
	props = get_node("/root/Game/Walls/Props")
	
	print(walkable.get_used_cells()[0])
	
	walkable_cells = walkable.get_used_cells()
	walkable_cells.shuffle()
	
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
	new_goo.set_network_master(get_tree().get_network_unique_id())
	get_node("/root/Game/Walls/Props").add_child(new_goo)
	

func get_valid_position():
	
	var position = Vector2.ZERO
	var is_valid = false

	while not is_valid:
		position = walkable_cells[Random.randi() % walkable_cells.size()] * walkable.cell_size + walkable.cell_size / 2
		var too_close_to_player = false
		for player in get_tree().get_nodes_in_group("Player"):
			if position.distance_to(player.global_position) <= (150 / 2):
				too_close_to_player = true
				break

		if not too_close_to_player:
			return position
