extends Control

var player_items
var item

var progress: float = 0.0
func _ready():
	set_process(false)
	call_deferred("get_player")
	
func set_process(is_process: bool):
	visible = is_process
	.set_process(is_process)
	
func get_player():
	
	for _player in get_tree().get_nodes_in_group("Player"):
		if int(_player.name) == get_tree().get_network_unique_id():
			player_items = _player.get_node("Items")
	
	player_items.connect("item_changed", self, "on_item_changed")
	on_item_changed()
	
func on_item_changed():
	item = player_items.item
	item.connect("is_reloading", self, "set_process", [true])

func _process(delta):
	rect_position = get_viewport().get_mouse_position() / 4
	var progress = 1 - (item.reload_timer.time_left / item.reload_time)
	
	$VBoxContainer/Control/ReloadBar.visible = item.can_quick_reload
	$VBoxContainer/Control/ReloadBarNoQuickReload.visible = not item.can_quick_reload

	var in_quick_reload_interval = item.in_quick_reload_interval()
	$VBoxContainer/Control/Control/Normal.visible = not in_quick_reload_interval
	$VBoxContainer/Control/Control/QuickReload.visible = in_quick_reload_interval
	
	$VBoxContainer/Control/Control.rect_position.x = progress * 26

	if item.reload_timer.is_stopped():
		set_process(false)
