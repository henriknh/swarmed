extends Node2D

export(PackedScene) var player_instance
export(PackedScene) var goo_instance

func _ready():
	
	get_tree().connect("network_peer_disconnected", self, "on_player_disconnected")
	get_tree().connect('network_peer_connected', self, "create_player")
	get_tree().connect("server_disconnected", self, "on_server_disconnected")
	
	var local_player_id = get_tree().get_network_unique_id()
	create_player(local_player_id)
	
	if not get_tree().is_network_server():
		rpc_id(1, '_request_players', local_player_id)
	
	$CanvasModulate.visible = true
	$CanvasLayer.offset = Vector2.ZERO
	
	Spawner.init()

func on_player_disconnected(id):
	get_node(str(id)).queue_free()

func on_server_disconnected():
	get_tree().change_scene("res://scenes/menu.tscn")
	
remote func _request_players(request_from_id):
	if get_tree().is_network_server():
		for player in get_tree().get_nodes_in_group("Player"):
			print("%d %d" % [int(player.name), request_from_id])
			if int(player.name) != request_from_id:
				print("sending ")
				rpc_id(request_from_id, '_send_player', int(player.name))
				
remote func _send_player(player_id: int):
	if not get_node(str(player_id)):
		create_player(player_id)
	
func create_player(player_id: int):
	var new_player = player_instance.instance()
	new_player.name = str(player_id)
	new_player.set_network_master(player_id)
	add_child(new_player)
