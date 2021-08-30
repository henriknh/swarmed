extends KinematicBody2D

class_name Entity

onready var anim_player: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

puppet var puppet_position = Vector2.ZERO
puppet var puppet_anim

signal entity_changed

func _ready():
	puppet_anim = anim_player.get_current_node()
	
	call_deferred("add_child", preload("res://entities/siluette.tscn").instance())

func set_anim(anim: String):
	if anim != anim_player.get_current_node():
		anim_player.travel(anim)
	
	if is_network_master():
		rset("puppet_anim", anim)
