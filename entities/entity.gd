extends KinematicBody2D

class_name Entity

onready var anim_player: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

puppet var puppet_position = Vector2.ZERO
puppet var puppet_anim

func _ready():
	puppet_anim = anim_player.get_current_node()
	
	if get_node_or_null("Sprite"):
		get_node("Sprite").material = preload("res://materials/canvas_light_only.tres")

func set_anim(anim: String):
	if anim != anim_player.get_current_node():
		anim_player.travel(anim)
	
	if is_network_master():
		rset("puppet_anim", anim)
