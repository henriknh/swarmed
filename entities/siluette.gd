extends Node2D

func _ready():
	var viewport: Viewport = get_node_or_null("../Viewport")
	get_parent().move_child(self, viewport.get_index() + 1)
	if viewport:
		$Mask.texture = viewport.get_texture()
		$Output.texture = viewport.get_texture()
