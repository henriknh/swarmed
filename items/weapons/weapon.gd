extends Item

class_name Weapon

var weapon_cooldown_timer = Timer.new()
var weapon_on_cooldown = false

export(float) var cooldown_time = 0.5

func _ready():
	weapon_cooldown_timer.wait_time = cooldown_time
	weapon_cooldown_timer.one_shot = true
	weapon_cooldown_timer.connect("timeout", self, "on_cooldown_done")
	add_child(weapon_cooldown_timer)
	
	if get_node_or_null("Sprite"):
		get_node("Sprite").material = preload("res://materials/canvas_light_only.tres")

func run_cooldown():
	weapon_cooldown_timer.start()
	
func on_cooldown_done():
	weapon_on_cooldown = false
