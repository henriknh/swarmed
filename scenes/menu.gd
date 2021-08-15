extends CenterContainer

var first_run = true
func _ready():
	if first_run:
		first_run = false
		if "--host" in OS.get_cmdline_args():
			on_host()
		elif "--join" in OS.get_cmdline_args():
			on_join()
	
func on_host():
	var server_port = $VBoxContainer/HostPort.value
	var max_players = $VBoxContainer/HostMaxPlayers.value
	Network.host(server_port, max_players)
	go_to_game()

func on_join():
	var server_ip = $VBoxContainer/JoinIp.text
	var server_port = $VBoxContainer/JoinPort.value
	get_tree().connect("connected_to_server", self, "go_to_game")
	Network.join(server_ip, server_port)

func go_to_game():
	get_tree().change_scene("res://scenes/game.tscn")
