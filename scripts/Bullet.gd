extends Node2D

export(float) var Speed
export(float) var Max_Distance

var direction = 0
var distance = 0

func _physics_process(delta):
	var delta_pos = Vector2(direction*Speed*delta, 0)
	var space_state = get_world_2d().direct_space_state
	var hit = space_state.intersect_ray(position, position + delta_pos)
	if hit and hit['collider'].has_method('hit_by_bullet'):
		hit['collider'].hit_by_bullet()
		queue_free()
	distance += delta_pos.length()
	translate(delta_pos)

func _process(delta):
	if distance > Max_Distance:
		queue_free()
