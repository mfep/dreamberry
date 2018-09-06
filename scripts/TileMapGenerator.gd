extends TileMap

export(int) var Map_Width
export(int) var Map_Height
export(int) var Platforms_Per_Level
export(int) var Min_Offset
export(int) var Max_Offset
export(int) var Min_Platform_Length
export(int) var Max_Platform_Length

const GROUND_ROWS = 3

func do_blocks_pass():
	# ground
	for row in range(GROUND_ROWS):
		for col in range(Map_Width):
			set_cell(col, -row, 1)

	# side walls
	for row in range(GROUND_ROWS, Map_Height):
		set_cell(0, -row, 1)
		set_cell(Map_Width - 1, -row, 1)

	# platforms
	var levelIdx = GROUND_ROWS
	while (levelIdx < Map_Height - Max_Offset):
		for platformIdx in range(Platforms_Per_Level):
			var start_col = randi() % (Map_Width - Max_Platform_Length)
			var end_col = Min_Platform_Length + start_col + (randi() % (Max_Platform_Length - Min_Platform_Length))
			for col in range(start_col, end_col + 1):
				set_cell(col, -levelIdx, 1)
		levelIdx += Min_Offset + (randi() % (Max_Offset - Min_Offset))

func _ready():
	randomize()
	clear()
	do_blocks_pass()

func _input(event):
	if (event.is_action_pressed('ui_focus_next')):
		clear()
		do_blocks_pass()
