extends Area2D

export(float) var Speed
export(float) var Min_Change_Time
export(float) var Max_Change_Time

var direction_x = 0
var size = Vector2(32, 32)
var next_change = 0

func new_next_change():
	next_change = Min_Change_Time + randf() * (Max_Change_Time - Min_Change_Time)

func _ready():
	direction_x = -1 if randi() % 2 else 1
	new_next_change()

func _physics_process(delta):
	next_change -= delta
	if next_change < 0:
		direction_x *= -1
		new_next_change()
	
	var check_pos = position + Vector2(direction_x * size.x/2, size.y)
	var tilemap = $'../../TileMap'
	var tile = tilemap.world_to_map(check_pos)
	if tilemap.get_cellv(tile) == -1:
		direction_x *= -1
	translate(Vector2(direction_x, 0)*Speed*delta)