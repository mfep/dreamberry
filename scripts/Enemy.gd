extends Area2D

export(float) var Speed
export(float) var Min_Change_Time
export(float) var Max_Change_Time
export(float) var Dps

signal Killed
signal Player_Overlap(dps)

var explosion_scene = preload('res://scenes/Explosion.tscn')

var direction_x = 0
var size = Vector2(32, 32)
var next_change = 0

func new_next_change():
	next_change = Min_Change_Time + randf() * (Max_Change_Time - Min_Change_Time)

func hit_by_bullet():
	var explosion_node = explosion_scene.instance()
	explosion_node.position = position
	$'..'.add_child(explosion_node)
	explosion_node.restart()
	emit_signal('Killed')
	queue_free()

func _ready():
	direction_x = -1 if randi() % 2 else 1
	new_next_change()

func _process(delta):
	# collision with player
	var player = $'../../Player'
	if overlaps_body(player):
		emit_signal('Player_Overlap', Dps*delta*60)

	# update change
	next_change -= delta
	if next_change < 0:
		direction_x *= -1
		new_next_change()
	
	# check movement
	var tilemap = $'../../TileMap'
	var check_pos = position + Vector2(direction_x*size.x/2, 0)
	var tile = tilemap.world_to_map(check_pos)
	if tilemap.get_cellv(tile) != -1:
		direction_x *= -1
	else:
		check_pos = position + Vector2(direction_x*size.x/2, size.y)
		tile = tilemap.world_to_map(check_pos)
		if tilemap.get_cellv(tile) == -1:
			direction_x *= -1
	$AnimatedSprite.flip_h = direction_x < 0
	translate(Vector2(direction_x, 0)*Speed*delta)