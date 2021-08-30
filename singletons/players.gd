extends Node

var player: Player = null setget set_player

signal player_set

func set_player(_player: Player):
	player = _player
	emit_signal("player_set")
