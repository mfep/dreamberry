extends TileMap

export(int) var Map_Width
export(int) var Map_Height
export(int) var Platforms_Per_Level
export(int) var Min_Offset
export(int) var Max_Offset
export(int) var Min_Platform_Length
export(int) var Max_Platform_Length
export(int) var Ground_Rows

signal Map_generated(spawn_points, top_pos)
var spawn_points = []
var top_pos = Vector2()

func random_int_range(_min, _max):
	return _min + (randi() % (_max - _min + 1))

func do_blocks_pass():
	# ground
	for row in range(Ground_Rows):
		for col in range(Map_Width):
			set_cell(col, -row, 0)

	# side walls
	for row in range(Ground_Rows, Map_Height):
		set_cell(0, -row, 0)
		set_cell(Map_Width - 1, -row, 0)

	# platforms
	var level_idx = Ground_Rows
	while (level_idx < Map_Height - Max_Offset):
		for platform_idx in range(Platforms_Per_Level):
			var start_col = random_int_range(1, Map_Width - 1)
			var end_col = min(Map_Width - 2, start_col + random_int_range(Min_Platform_Length, Max_Platform_Length))
			for col in range(start_col, end_col + 1):
				set_cell(col, -level_idx, 0)
				spawn_points.append(map_to_world(Vector2(col, -level_idx)) + Vector2(cell_size.x/2, -cell_size.y/2))
		level_idx += Min_Offset + (randi() % (Max_Offset - Min_Offset))
		if level_idx >= Map_Height - Max_Offset:
			top_pos = map_to_world(Vector2(random_int_range(3, Map_Width - 3), -level_idx-1))

	# clear player pos
	set_cell(1, -Ground_Rows, -1)

const NONE = 0
const LEFT = 1
const RIGHT = 2
const TOP = 4
const BOTTOM = 8
const LEFT_RIGHT = LEFT | RIGHT
const LEFT_TOP = LEFT | TOP
const LEFT_BOTTOM = LEFT | BOTTOM
const RIGHT_TOP = RIGHT | TOP
const RIGHT_BOTTOM = RIGHT | BOTTOM
const TOP_BOTTOM = TOP | BOTTOM
const RIGHT_TOP_BOTTOM = RIGHT | TOP | BOTTOM
const LEFT_TOP_BOTTOM = LEFT | TOP | BOTTOM
const LEFT_RIGHT_BOTTOM = LEFT | RIGHT | BOTTOM
const LEFT_RIGHT_TOP = LEFT | RIGHT | TOP
const ALL = LEFT | RIGHT | TOP | BOTTOM

func do_autotile_pass():
	for cell in get_used_cells():
		var neighbors = 0
		if get_cell(cell.x - 1, cell.y) != -1: neighbors |= LEFT
		if get_cell(cell.x + 1, cell.y) != -1: neighbors |= RIGHT
		if get_cell(cell.x, cell.y - 1) != -1: neighbors |= TOP
		if get_cell(cell.x, cell.y + 1) != -1: neighbors |= BOTTOM
		var idx = 0
		match neighbors:
			NONE: idx = 0
			LEFT: idx = 3
			RIGHT: idx = 1
			TOP: idx = 8
			BOTTOM: idx = 2
			LEFT_RIGHT: idx = 2
			LEFT_TOP: idx = 9
			LEFT_BOTTOM: idx = 3
			RIGHT_TOP: idx = 7
			RIGHT_BOTTOM: idx = 1
			TOP_BOTTOM: idx = 5
			RIGHT_TOP_BOTTOM: idx = 4
			LEFT_TOP_BOTTOM: idx = 6
			LEFT_RIGHT_BOTTOM: idx = 2
			LEFT_RIGHT_TOP: idx = 8
			ALL: idx = 5
		set_cell(cell.x, cell.y, idx)

func generate():
	clear()
	spawn_points.clear()
	do_blocks_pass()
	do_autotile_pass()
	emit_signal('Map_generated', spawn_points, top_pos)

func _ready():
	randomize()
	generate()

func _input(event):
	if (get_node('/root/global').DEBUG and event.is_action_pressed('ui_focus_next')):
		generate()
