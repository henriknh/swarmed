extends Entity

class_name Unit

export(int) var max_health = 1
onready var health = max_health setget set_health

export (int) var max_energy = 3
onready var energy = max_energy setget set_energy
onready var recharge_energy_timer = Timer.new()

export(int) var max_armor = 0
onready var armor = max_armor setget set_armor
onready var recharge_armor_timer = Timer.new()

var is_dead = false

func _onready():
	recharge_energy_timer.wait_time = 2
	recharge_energy_timer.one_shot = true
	recharge_energy_timer.connect("timeout", self, "on_recharge_energy")
	add_child(recharge_energy_timer)
	
	recharge_armor_timer.wait_time = 10
	recharge_armor_timer.one_shot = true
	recharge_armor_timer.connect("timeout", self, "on_recharge_armor")
	add_child(recharge_armor_timer)
	
func set_health(_health):
	var diff = _health - health
	
	if diff < 0 and armor > 0:
		self.armor += diff
		if armor < 0:
			health += armor
			armor = 0
	else:
		health += diff
	
	if health <= 0:
		dead()
	
	emit_signal("entity_changed")
	
func set_energy(_energy: int):
	energy = _energy
	
	if energy < 0:
		energy = 0
	
	if energy > max_energy:
		energy = max_energy
	
	if energy < max_energy and recharge_energy_timer.is_stopped():
		recharge_energy_timer.start()
	
	emit_signal("entity_changed")

func on_recharge_energy():
	set_energy(energy + 1)
	
func set_armor(_armor: int):
	armor = _armor
	
	if armor < 0:
		armor = 0
	
	if armor > max_armor:
		armor = max_armor
	
	if armor < max_armor and recharge_armor_timer.is_stopped():
		recharge_armor_timer.start()
	
	emit_signal("entity_changed")
	
func on_recharge_armor():
	set_armor(armor + 1)

func dead():
	if not is_dead:
		is_dead = true
		$CollisionShape2D.disabled = true
		set_anim("dead")
		set_process(false)
		set_physics_process(false)
		
		var s: Sprite = Sprite.new()
		s.texture = $Viewport.get_texture()
		var material = CanvasItemMaterial.new()
		material.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
		s.material = material
		add_child(s)
		
		$CollisionShape2D.disabled = true
		
		#remove_child($Viewport)
		remove_child($Siluette)
		emit_signal("entity_changed")


		if has_method("clear_target"):
			call("clear_target")
