extends Node2D

export(int) var max_items = 4
var item: Item = null
signal items_changed

func _ready():
	if get_child_count():
		item = get_child(0)
		item.equipped = true
		emit_signal("items_changed")

func _input(event):
	if Input.is_action_just_pressed("prev_item") or Input.is_action_just_pressed("next_item"):
		var item_idx = get_children().find(item)
		
		if Input.is_action_just_pressed("prev_item"):
			var prev_idx = (item_idx - 1 + max_items) % max_items
			item = get_child(prev_idx)
			emit_signal("items_changed")
		elif Input.is_action_just_pressed("next_item"):
			var next_idx = (item_idx + 1 + max_items) % max_items
			item = get_child(next_idx)
			emit_signal("items_changed")
			
		for _item in get_children():
			_item.visible = _item == item
			_item.equipped = _item == item
