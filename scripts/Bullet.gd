extends Area2D

export(float) var Speed;

var direction = 0

func _process(delta):
	if not $VisibilityNotifier2D.is_on_screen():
		queue_free()
	translate(Vector2(direction*Speed*delta, 0))