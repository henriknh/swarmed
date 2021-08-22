extends Unit

export (int) var speed = 500
export (int) var max_speed = 40

var velocity = Vector2.ZERO

export (int) var roll_speed = 500
export (int) var max_rolling_speed = 100
export(int) var roll_cost = 2
var is_rolling = false
puppet var puppet_is_rolling = is_rolling

onready var camera: Camera2D = get_node("/root/Game/Camera2D")
onready var window_size = Vector2(ProjectSettings.get("display/window/size/width"), ProjectSettings.get("display/window/size/height"))
onready var sprite: Sprite = $Viewport/Sprite

puppet var puppet_facing = 0
	
func _ready():
	._onready()
	if is_network_master():
		$RemoteTransform2D.remote_path = get_node("/root/Game/Camera2D").get_path()
	
func get_inputs() -> Vector2:
	
	var axis = Vector2.ZERO
	axis.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	axis.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return axis.normalized()

func _physics_process(delta):
	if is_network_master():
		var axis = get_inputs()
		
		if Input.is_action_just_pressed("roll") and energy >= roll_cost and not is_rolling and axis != Vector2.ZERO:
			self.energy -= roll_cost
			is_rolling = true
			rset("puppet_is_rolling", is_rolling)

		var relative_mouse_position = get_global_mouse_position() - global_position
		var window_size_offsetted = window_size * camera.zoom / 2
		var mouse_location = relative_mouse_position / window_size_offsetted
		
		var facing = mouse_location.x
		sprite.flip_h = facing < 0
		rset("puppet_facing", facing)
		
		camera.offset_h = lerp(camera.offset_h, mouse_location.x * 0.2, delta * 20)
		camera.offset_v = lerp(camera.offset_v, mouse_location.y * 0.1, delta * 20)
		
		if is_rolling:
			velocity += velocity.normalized() * roll_speed * delta
			if velocity.length() > max_rolling_speed:
				velocity = velocity.normalized() * max_rolling_speed
		elif axis == Vector2.ZERO:
			if velocity.length() > speed * delta:
				velocity -= velocity.normalized() * speed * delta
			else:
				velocity = Vector2.ZERO
		else:
			velocity += axis * speed * delta
			if velocity.length() > max_speed:
				velocity = velocity.normalized() * max_speed
		
		collision_layer = 0 if is_rolling else 2
		move_and_slide(velocity)
		
		if is_rolling:
			set_anim("roll")
		elif velocity.length() > 0:
			set_anim("walk")
		else:
			set_anim("idle")
		
		rset_unreliable("puppet_position", position)
	else:
		collision_layer = 0 if is_rolling else 2
		position = puppet_position
		sprite.flip_h = puppet_facing < 0
		set_anim(puppet_anim)

func roll_complete():
	is_rolling = false
	rset("puppet_is_rolling", is_rolling)

func _on_body_entered(body):
	if body is Enemy and body.has_method("on_alert"):
		body.on_alert(self)

func play_step():
	($Steps.stream as AudioStreamOGGVorbis).loop = false
	if $Steps.playing:
		$Steps.stop()
	$Steps.play()

