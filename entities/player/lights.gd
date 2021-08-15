extends Light2D

export(int) var speed = 2

var time = 0
var initial_scale = []
var offsets = []

func _ready():
	visible = int(get_parent().name) == get_tree().get_network_unique_id()
	set_physics_process(visible)
	
	for child in get_children():
		initial_scale.append(child.scale)
		offsets.append(Random.randf())

func _physics_process(delta):
	time += delta * speed
	
	for i in range(offsets.size()):
		get_child(i).scale = initial_scale[i] * (0.9 + sin(offsets[i] + time) / 40 + .025)
	

