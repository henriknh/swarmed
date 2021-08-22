extends Node

var spawn_node: Node2D
onready var spawn_timer = Timer.new()
var walkable: TileMap
var walkable_cells: Array
var unique_id = 0

func init():
	spawn_node = get_node("/root/Game/YSort/Walls/Props")
	
	walkable = get_node("/root/Game/Navigation2D/Walkable")
	walkable_cells = walkable.get_used_cells()
	walkable_cells.shuffle()
	
	if get_tree().is_network_server():
		for _i in range(10):
			create_goo()
	
	spawn_timer.autostart = true
	spawn_timer.wait_time = Random.randf() * 2 + 1
	spawn_timer.connect("timeout", self, "on_create_goo")
	#get_node("/root/Game").add_child(spawn_timer)

func on_create_goo():
	spawn_timer.stop()
	spawn_timer.wait_time = Random.randf() * 2 + 1
	call_deferred("create_goo")
	spawn_timer.start()
	
func create_goo():
	var new_goo = preload("res://entities/enemies/goo/goo.tscn").instance()
	new_goo.position = get_valid_position()
	rpc("spawn", new_goo)
	
sync func spawn(instance):
	unique_id += 1
	instance.name = "%d_%d" % [get_tree().get_network_unique_id(), unique_id]
	instance.set_network_master(get_tree().get_network_unique_id())
	spawn_node.call_deferred("add_child", instance)
	
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
