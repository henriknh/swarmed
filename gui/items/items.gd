extends Control

func _ready():
	Players.connect("player_set", self, "on_player_set")
	
func on_player_set():
	Players.player.get_node("Items").connect("items_changed", self, "on_items_changed")
	call_deferred("on_items_changed")
	
func on_items_changed():
	for idx in range(Players.player.get_node("Items").get_child_count()):
		Players.player.get_node("Items").get_child(idx).connect("item_changed", self, "on_item_changed", [idx])
		on_item_changed(idx)

func on_item_changed(idx):
	var item = Players.player.get_node("Items").get_child(idx)
	var node = get_child(idx)
	
	var node_background: TextureRect = node.get_node_or_null("Background")
	var node_icon: TextureRect = node.get_node_or_null("Icon")
	var cooldown: TextureProgress = node.get_node_or_null("Cooldown")
	
	if item:
		node_background.self_modulate = Color.white
		node_icon.texture = item.icon
		var progress = 0
		if item.cooldown_timer.time_left > 0:
			progress = (item.cooldown_timer.time_left / item.cooldown_timer.wait_time) * 100
		cooldown.value = progress
	else:
		node_background.self_modulate = Color(1, 1, 1, 0.5)
		node_icon.texture = null
		cooldown.value = 0
	

func _physics_process(delta):
	for idx in range(Players.player.get_node("Items").get_child_count()):
		on_item_changed(idx)
