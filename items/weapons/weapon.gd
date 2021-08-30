extends Item

class_name Weapon

export(float) var cooldown_time = 0.5

func _ready():
	call_deferred("add_child", preload("res://entities/siluette.tscn").instance())
	._ready()
