extends Node2D

class_name Item

export(Texture) var icon

onready var equip_timer = Timer.new()
export(float) var equip_time = 0.3
var equipped: bool = false setget set_equipped

func _ready():
	equip_timer.one_shot = true
	equip_timer.wait_time = equip_time
	equip_timer.connect("timeout", self, "on_equip")
	add_child(equip_timer)
	
func set_equipped(_eqipped):
	if _eqipped:
		equip_timer.start()
	else:
		equipped = false
		set_physics_process(false)
		equip_timer.stop()

func on_equip():
	equipped = true
	set_physics_process(true)


