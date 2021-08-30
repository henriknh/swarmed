extends Control 

func _ready():
	var mouse_cursor = AtlasTexture.new()
	mouse_cursor.atlas = preload("res://assets/spritesheets/ui.png")
	mouse_cursor.region = Rect2(11, 11, 26, 26)
	Input.set_custom_mouse_cursor(mouse_cursor, 0, Vector2(13, 13))
	
func _physics_process(delta):
	$TopRight/FpsCounter.text = Engine.get_frames_per_second() as String
