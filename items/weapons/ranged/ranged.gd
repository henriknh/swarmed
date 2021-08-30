extends Weapon

class_name Ranged

export(AudioStreamOGGVorbis) var firing_sound
export(PackedScene) var projectile_instance
export(int) var max_bullets = 8
export(int) var bullets_per_shot = 1
export(bool) var automatic_fire = false
export(int) var projectile_spread = 10

onready var bullets = max_bullets
var shooting = false
var waiting_for_release = false

puppet var puppet_rotation = 0
puppet var puppet_flip_v = false

signal is_reloading
export(float) var reload_time = 1
var can_quick_reload = false
var quick_reload_lower_bound = 17.0 / 36.0
var quick_reload_upper_bound = 27.0 / 36.0

func _physics_process(delta):
	if not visible:
		return
	
	_handle_sprite()
	
	if not equipped:
		return
	
	_handle_inputs()
	
	if automatic_fire and shooting:
		shoot()

func _handle_sprite():
	if is_network_master():
		var mouse_position = get_global_mouse_position()
		look_at(mouse_position)
	
		$Viewport/Sprite.flip_v = mouse_position.x < global_position.x
		position.x = -1 if mouse_position.x < global_position.x else 1
		
		rset("puppet_rotation", rotation)
		rset("puppet_flip_v", $Viewport/Sprite.flip_v)
	else:
		rotation = puppet_rotation
		$Viewport/Sprite.flip_v = puppet_flip_v
		position.x = -1 if puppet_flip_v else 1

func _handle_inputs():
	if is_network_master():
		if automatic_fire:
			shooting = Input.is_action_pressed("trigger_item")
		elif Input.is_action_just_pressed("trigger_item") and not waiting_for_release:
			waiting_for_release = true
			shoot()
			
		if Input.is_action_just_released("trigger_item"):
			waiting_for_release = false
		
		if Input.is_action_just_pressed("reload"):
			if cooldown_timer.is_stopped():
				cooldown_timer.connect("timeout", self, "on_reloaded")
				set_cooldown(reload_time)
				emit_signal("is_reloading")
				can_quick_reload = true
			elif can_quick_reload:
				if in_quick_reload_interval():
					set_cooldown_done()
					on_reload()
				else:
					set_cooldown(reload_time)
					can_quick_reload = false

func shoot():
	if get_parent().get_parent().is_rolling: 
		return
	
	if ready:
		if bullets > 0:
			bullets -= bullets_per_shot
			emit_signal("item_changed")
			set_cooldown(cooldown_time)
			create_bullet($Mussle.global_position, global_rotation)
		else:
			var sound_empty_mag: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			sound_empty_mag.stream = firing_sound
			sound_empty_mag.connect("finished", sound_empty_mag, "queue_free")
			sound_empty_mag.stream.loop = false
			sound_empty_mag.volume_db = -10
			add_child(sound_empty_mag)
			sound_empty_mag.play()

func create_bullet(position: Vector2, rotation: float):
	for i in range(bullets_per_shot):
		var mussle_flash = preload("res://items/weapons/ranged/mussle_flash.tscn").instance()
		mussle_flash.global_position = position
		mussle_flash.global_rotation = rotation
		Spawner.rpc("spawn", mussle_flash)
		
		var projectile = projectile_instance.instance()
		projectile.projectile_spread = projectile_spread
		projectile.global_position = position
		projectile.global_rotation = rotation
		Spawner.rpc("spawn", projectile)

func on_reload():
	cooldown_timer.disconnect("timeout", self, "on_reloaded")
	bullets = max_bullets
	emit_signal("item_changed")

func in_quick_reload_interval() -> bool:
	if not can_quick_reload:
		return false
	var progress = 1 - (cooldown_timer.time_left / reload_time)
	return quick_reload_lower_bound < progress and progress < quick_reload_upper_bound
