extends Entity

class_name Unit

export(int) var max_health = 1
onready var health = max_health setget set_health

export (int) var max_energy = 3
onready var energy = max_energy setget set_energy
onready var recharge_energy_timer = Timer.new()

export (int) var armor = 0

func _onready():
	recharge_energy_timer.wait_time = 2
	recharge_energy_timer.one_shot = true
	recharge_energy_timer.connect("timeout", self, "on_recharge_energy")
	add_child(recharge_energy_timer)
	
func set_health(_health):
	var diff = _health - health
	
	if diff < 0 and armor > 0:
		armor += diff
		if armor < 0:
			health += armor
			armor = 0
	else:
		health += diff
	
	if health <= 0:
		queue_free()
	
func set_energy(_energy: int):
	energy = _energy
	
	if energy < 0:
		energy = 0
	
	if energy > max_energy:
		energy = max_energy
	
	if energy < max_energy and recharge_energy_timer.is_stopped():
		recharge_energy_timer.start()

func on_recharge_energy():
	set_energy(energy + 1)
