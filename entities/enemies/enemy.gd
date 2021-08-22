extends Unit

class_name Enemy

export(int) var target_lost_distance = 150
export(int) var speed = 25

onready var anim_tree: AnimationTree = $AnimationTree
onready var nav: Navigation2D = get_node("/root/Game/Navigation2D")
onready var on_target_reset = position
var target: KinematicBody2D = null
var velocity = Vector2.ZERO

func _ready():
	clear_target()

func _physics_process(delta):
	return
	if is_instance_valid(target):
		if not move_to(target.global_position):
			clear_target()
	else:
		clear_target()
		if on_target_reset.distance_to(global_position) > 2:
			move_to(on_target_reset)

func move_to(target_postition: Vector2) -> bool:
	var path_to_target = nav.get_simple_path(global_position, target_postition)
	
	if path_to_target.size():
		
		var velocity = (path_to_target[1] - global_position).normalized()
		
		velocity = move_and_slide(velocity * speed)
		move_and_slide( Vector2( 0.0, 0.0 ) )
		
		if velocity.length() > 0:
			set_anim("walk")
			if abs(velocity.x) > 0:
				$Viewport/Sprite.scale.x = -1 if velocity.x < 0 else 1
		else:
			set_anim("idle")
	
		if get_distance_to_path(path_to_target) > target_lost_distance:
			return false
			
		return true
	else:
		return false

func clear_target():
	set_physics_process(false)
	anim_tree.active = false
	target = null

func on_alert(source: KinematicBody2D):
	target = source
	on_target_reset = global_position
	set_physics_process(true)
	anim_tree.active = true
	
func get_distance_to_path(path_to_target: PoolVector2Array):
	var distance = 0
	var prev = global_position
	
	for point in path_to_target:
		distance += prev.distance_to(point)
		prev = point
		
	return distance
