extends KinematicBody2D

export(float) var Acceleration
export(float) var Max_Speed
export(float) var Jump_Height
export(float) var Jump_Time

var velocity = Vector2()
var gravity = 0
var jump_velocity = 0
var start_pos = Vector2()

func _ready():
	start_pos = position
	gravity = -2*Jump_Height/Jump_Time/Jump_Time
	jump_velocity = abs(gravity)*Jump_Time
	print('gravity:', gravity, ' jump velocity:', jump_velocity)

func _physics_process(delta):
	var input_x = 0
	if (Input.is_action_pressed('ui_left')): input_x += -1
	if (Input.is_action_pressed('ui_right')): input_x += 1
	
	var desired_vel_x = input_x*Max_Speed
	var accelerate_dir = sign(desired_vel_x - velocity.x)
	var new_vel_x = clamp(velocity.x + accelerate_dir*Acceleration, -Max_Speed, Max_Speed)
	
	# remove scattering
	if ((velocity.x - desired_vel_x)*(new_vel_x - desired_vel_x) < 0):
		new_vel_x = desired_vel_x
	# snappy
	if (new_vel_x*desired_vel_x < 0):
		new_vel_x = 0

	# jumping
	var jump = 0
	if (Input.is_action_just_pressed('ui_accept') and is_on_floor()):
		jump = 1
	var new_vel_y = velocity.y - gravity*delta - jump*jump_velocity
	velocity = move_and_slide(Vector2(new_vel_x, new_vel_y), Vector2(0, -1))

func _input(event):
	if (get_node('/root/global').DEBUG and event.is_action_pressed('ui_focus_next')):
		position = start_pos
