extends Control

onready var value: HBoxContainer = $Control/Value
onready var label: Label = $Control/Label

export(int) var armor_scale = 12

func _ready():
	Players.connect("player_set", self, "on_player_set")
	rect_size.x = 0
	value.rect_size.x = 0
	
func on_player_set():
	Players.player.connect("entity_changed", self, "on_entity_changed")
	call_deferred("on_entity_changed")

func on_entity_changed():
	rect_min_size.x = Players.player.max_armor * armor_scale
	rect_size.x = Players.player.max_armor * armor_scale
	
	value.visible = Players.player.armor > 0
	value.rect_min_size.x = Players.player.armor * armor_scale
	value.rect_size.x = Players.player.armor * armor_scale
	
	label.text = "%d" % Players.player.armor
