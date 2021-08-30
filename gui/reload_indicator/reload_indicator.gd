extends Control

var player_items
var item

var progress: float = 0.0

onready var bar_reload = $VBoxContainer/Bars/ReloadBar
onready var bar_no_quick_reload = $VBoxContainer/Bars/ReloadBarNoQuickReload
onready var nobs = $VBoxContainer/Bars/Nobs
onready var nob_normal = $VBoxContainer/Bars/Nobs/Normal
onready var nob_quick_reload = $VBoxContainer/Bars/Nobs/QuickReload

func _ready():
	set_process(false)
	Players.connect("player_set", self, "on_player_set")
	
func set_process(is_process: bool):
	visible = is_process
	.set_process(is_process)
	
func on_player_set():
	player_items = Players.player.get_node("Items")
	player_items.connect("items_changed", self, "on_items_changed")
	on_items_changed()
	
func on_items_changed():
	item = player_items.item
	if item:
		item.connect("is_reloading", self, "set_process", [true])

func _process(delta):
	rect_position = get_viewport().get_mouse_position() / 2
	var progress = 1 - (item.cooldown_timer.time_left / item.reload_time)
	
	bar_reload.visible = item.can_quick_reload
	bar_no_quick_reload.visible = not item.can_quick_reload

	var in_quick_reload_interval = item.in_quick_reload_interval()
	nob_normal.visible = not in_quick_reload_interval
	nob_quick_reload.visible = in_quick_reload_interval
	
	nobs.rect_position.x = progress * 34

	if item.cooldown_timer.is_stopped():
		set_process(false)
