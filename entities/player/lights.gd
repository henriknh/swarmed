extends Light2D

export(int) var speed_base = 2
export(int) var speed_factor = 13

onready var time = Random.randf()

func _ready():
	visible = int(get_parent().name) == get_tree().get_network_unique_id()
	set_physics_process(visible)
	
	scale = Vector2.ONE  * get_vision_radius()

func _physics_process(delta):
	get_parent().health = 1
	
	scale = Vector2.ONE  * lerp(scale.x, get_vision_radius(delta), delta * (2  + 3 * get_heart_rate()))
	
func get_heart_rate() -> float:
	var max_health = float(get_parent().max_health)
	var health = get_parent().health if get_parent().health else max_health
	
	return 1 - (health / max_health)

func get_breathing(delta: float = 0) -> float:
	var heart_rate = get_heart_rate()
	var breathing_rate = 0.005 + heart_rate * 0.025
	time += delta * (speed_base + speed_factor * heart_rate)
	return sin(time) * breathing_rate
	
func get_vision_radius(delta: float = 0) -> float:
	return (1 - get_heart_rate() * 0.5) - get_breathing(delta)
