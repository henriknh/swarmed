extends Unit

export (int) var speed = 40
export (int) var roll_speed = 80

export (int) var max_energy = 3
onready var energy = max_energy setget set_energy

var velocity = Vector2.ZERO

export(int) var roll_cost = 2
var is_rolling = false
var roll_trijectory = Vector2.ZERO

onready var camera: Camera2D = get_node("/root/Game/Camera2D")
onready var window_size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))

puppet var puppet_facing = 0

var item: Item = null
	
func _ready():
	if is_network_master():
		$RemoteTransform2D.remote_path = get_node("/root/Game/Camera2D").get_path()
		
	item = $Weapon.get_child(0)
	
func get_inputs():
	
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		velocity.x += -1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	
	if Input.is_action_pressed("ui_up"):
		velocity.y += -1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		
	velocity = velocity.normalized()
	
	if Input.is_action_just_pressed("roll") and energy >= roll_cost and not is_rolling:
		do_roll()

func _physics_process(delta):
	if is_network_master():
		get_inputs()
	
		if is_rolling:
			velocity = move_and_slide(roll_trijectory * roll_speed)
			if abs(velocity.x) > 0:
				$Sprite.flip_h = velocity.x < 0
		else:
			var relateive_mouse_position = get_global_mouse_position() - global_position
			var window_size_offsetted = window_size * camera.zoom / 2
			var mouse_location = relateive_mouse_position / window_size_offsetted
			var facing = mouse_location.x
			
			$Sprite.flip_h = facing < 0
			
			camera.offset_h = lerp(camera.offset_h, facing * 0.4, delta * 20)
			camera.offset_v = lerp(camera.offset_v, mouse_location.y * 0.2, delta * 20)
			
			rset("puppet_facing", facing)
			
			velocity = move_and_slide(velocity * speed)
			if velocity.length() > 0:
				set_anim("walk")
			else:
				set_anim("idle")
		
		rset_unreliable("puppet_position", position)
	else:
		position = puppet_position
		$Sprite.flip_h = puppet_facing < 0
		set_anim(puppet_anim)

func do_roll():
	self.energy -= roll_cost
	is_rolling = true
	roll_trijectory = velocity
	set_anim("roll")

func roll_complete():
	is_rolling = false
	
func set_energy(_energy: int):
	energy = _energy
	if energy < max_energy and $RechargeEnergy.is_stopped():
		$RechargeEnergy.start()

func on_recharge_energy():
	self.energy += 1
	if energy >= max_energy:
		self.energy = max_energy

func _on_body_entered(body):
	if body is Enemy and body.has_method("on_alert"):
		body.on_alert(self)
