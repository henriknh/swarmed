extends Node

func host(server_port: int, max_players: int):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(server_port, max_players)
	get_tree().network_peer = peer

func join(server_ip: String, server_port: int):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, server_port)
	get_tree().network_peer = peer
