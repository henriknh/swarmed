extends Control

var item: Item = null

func _ready():
	Players.connect("player_set", self, "player_set")
	
func player_set():
	Players.player.get_node("Items").connect("items_changed", self, "on_items_changed")
	on_items_changed()
	
func on_items_changed():
	item = Players.player.get_node("Items").item
	if item:
		item.connect("item_changed", self, "on_item_changed")
	on_item_changed()
	
func on_item_changed():
	visible = item is Ranged
	
	if visible:
		for child in get_children():
			remove_child(child)
			
		for _i in range(item.max_bullets - item.bullets):
			add_child(preload("res://gui/ammo/empty_bullet.tscn").instance())
		for _i in range(item.bullets):
			add_child(preload("res://gui/ammo/bullet.tscn").instance())
