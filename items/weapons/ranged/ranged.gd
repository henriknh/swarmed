extends Weapon

class_name Ranged

var bullet_instance = preload("res://items/weapons/ranged/bullet/bullet.tscn")

export(int) var max_bullets = 8
export(int) var bullets_per_shot = 1
export(bool) var automatic_fire = false
export(int) var bullet_spread = 10

onready var bullets = max_bullets
var shooting = false
var waiting_for_release = false

puppet var puppet_rotation = 0
puppet var puppet_flip_v = false

func _physics_process(delta):
	if automatic_fire and shooting:
		shoot()
		
	if is_network_master():
		var mouse_position = get_global_mouse_position()
		look_at(mouse_position)
	
		$Sprite.flip_v = mouse_position.x < global_position.x
		position.x = -1 if mouse_position.x < global_position.x else 1
		
		rset("puppet_rotation", rotation)
		rset("puppet_flip_v", $Sprite.flip_v)
	else:
		rotation = puppet_rotation
		$Sprite.flip_v = puppet_flip_v
		position.x = -1 if puppet_flip_v else 1
		
func shoot():
	if not weapon_on_cooldown and bullets > 0:
		bullets -= bullets_per_shot
		weapon_on_cooldown = true
		run_cooldown()
		rpc("create_bullet", $Sprite/Mussle.global_position, $Sprite/Mussle.global_rotation)

sync func create_bullet(position: Vector2, rotation: float):
	for i in range(bullets_per_shot):
		
		
		var bullet = bullet_instance.instance()
		
		bullet.bullet_spread = bullet_spread
		bullet.global_position = position
		bullet.global_rotation = rotation
		
		(self as Node2D).get_node("/root/Game").call_deferred("add_child", bullet)
		#.add_child(bullet)

func reload():
	bullets = max_bullets

func _input(event):
	if is_network_master():
		if automatic_fire:
			shooting = Input.is_action_pressed("trigger_item")
		elif Input.is_action_just_pressed("trigger_item") and not waiting_for_release:
			waiting_for_release = true
			shoot()
			
		if Input.is_action_just_released("trigger_item"):
			waiting_for_release = false
		
		if Input.is_action_just_pressed("reload"):
			reload()
