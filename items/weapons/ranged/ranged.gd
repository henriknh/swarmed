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
onready var reload_timer = Timer.new()
export(float) var reload_time = 1
var can_quick_reload = false

func _ready():
	reload_timer.name = "ReloadTimer"
	reload_timer.one_shot = true
	reload_timer.wait_time = reload_time
	reload_timer.connect("timeout", self, "reload")
	add_child(reload_timer)

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
			if reload_timer.is_stopped():
				reload_timer.start()
				emit_signal("is_reloading")
				can_quick_reload = true
			elif can_quick_reload:
				if in_quick_reload_interval():
					reload()
				else:
					reload_timer.start()
					can_quick_reload = false

func shoot():
	if not weapon_on_cooldown and reload_timer.time_left == 0:
		
		if bullets > 0:
			bullets -= bullets_per_shot
			weapon_on_cooldown = true
			run_cooldown()
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

func reload():
	reload_timer.stop()
	bullets = max_bullets

func in_quick_reload_interval() -> bool:
	if not can_quick_reload:
		return false
	var progress = 1 - (reload_timer.time_left / reload_time)
	return 0.5 < progress and progress < 0.75
