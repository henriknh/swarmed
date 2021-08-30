extends Node2D

class_name Item

export(Texture) var icon

onready var cooldown_timer = Timer.new()
export(float) var equip_time = 0.5
var equipped: bool = false setget set_equipped
var ready: bool = false

signal item_changed

func _ready():
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = equip_time
	cooldown_timer.connect("timeout", self, "on_cooldown_timer")
	add_child(cooldown_timer)
	
func set_equipped(_eqipped):
	if _eqipped:
		set_cooldown(equip_time)
	else:
		equipped = false
		ready = false
		cooldown_timer.stop()
		emit_signal("item_changed")

func set_cooldown(time: float = equip_time):
	ready = false
	if cooldown_timer.is_stopped() or cooldown_timer.time_left < equip_time:
		cooldown_timer.start(time)
		
	emit_signal("item_changed")
	
func set_cooldown_done():
	cooldown_timer.stop()
	on_cooldown_timer()

func on_cooldown_timer():
	equipped = true
	ready = true
	emit_signal("item_changed")


