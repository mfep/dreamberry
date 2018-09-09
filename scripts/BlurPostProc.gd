extends TextureRect

func _process(delta):
	var screen_pos = $'../../Player'.get_global_transform_with_canvas().origin
	var window_size = get_viewport().size
	var uv = Vector2(screen_pos.x/window_size.x, 1-screen_pos.y/window_size.y)
	material.set_shader_param('center', uv)
