extends Node

var spawn_node: TileMap
onready var spawn_timer = Timer.new()
var walkable_cells: Array = []
var unique_id = 0

var prefab_goo = preload("res://entities/enemies/goo/goo.tscn")
var prefab_dust = preload("res://entities/enemies/dust/dust.tscn")

var enemy_prefabs = [
	prefab_goo,
	prefab_dust
]

func init():
	spawn_node = get_node("/root/Game/Navigation2D/Level")
	
	if get_tree().is_network_server():
		for _i in range(10):
			create_random_enemy()
	
	spawn_timer.autostart = true
	spawn_timer.wait_time = Random.randf() * 2 + 1
	spawn_timer.connect("timeout", self, "on_create_random_enemy")
	get_node("/root/Game").add_child(spawn_timer)

func on_create_random_enemy():
	spawn_timer.stop()
	spawn_timer.wait_time = Random.randf() * 2 + 1
	call_deferred("create_random_enemy")
	spawn_timer.start()
	
func create_random_enemy():
	var new_enemy = enemy_prefabs[Random.randi() % enemy_prefabs.size()].instance()
	new_enemy.position = get_valid_position()
	rpc("spawn", new_enemy)
	
sync func spawn(instance):
	unique_id += 1
	instance.name = "%d_%d" % [get_tree().get_network_unique_id(), unique_id]
	instance.set_network_master(get_tree().get_network_unique_id())
	spawn_node.call_deferred("add_child", instance)
	
func get_valid_position():
	var position = Vector2.ZERO
	var is_valid = false

	while not is_valid:
		position = walkable_cells[Random.randi() % walkable_cells.size()]
		var too_close_to_player = false
		for player in get_tree().get_nodes_in_group("Player"):
			if position.distance_to(player.global_position) <= (150 / 2):
				too_close_to_player = true
				break

		if not too_close_to_player:
			return position
