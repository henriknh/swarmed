extends Particles2D

var is_shotgun = false

func _ready():
	
	$AudioStreamPlayer2D.stream.loop = false
	
	if is_shotgun:
		amount = 8
		material.spread = 45
	emitting = true
