extends TileMap

export(int) var Map_Width
export(int) var Map_Height
export(int) var Platforms_Per_Level
export(int) var Min_Offset
export(int) var Max_Offset
export(int) var Min_Platform_Length
export(int) var Max_Platform_Length
export(int) var Ground_Rows

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
		level_idx += Min_Offset + (randi() % (Max_Offset - Min_Offset))

	# clear player pos
	set_cell(1, -Ground_Rows, -1)

func _ready():
	randomize()
	clear()
	do_blocks_pass()

func _input(event):
	if (get_node('/root/global').DEBUG and event.is_action_pressed('ui_focus_next')):
		clear()
		do_blocks_pass()
