extends Node

onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = 0

func randi():
	return rng.randi()

func randf():
	return rng.randf()
