extends KinematicBody2D

export(float) var Acceleration
export(float) var Max_Speed
export(float) var Jump_Height
export(float) var Jump_Time
export(float) var Shoot_Interval

signal Double_Jumped

var dust_scene = preload('res://scenes/DustParticles.tscn')
var bullett_scene = preload('res://scenes/Bullet.tscn')

var velocity = Vector2()
var gravity = 0
var jump_velocity = 0
var start_pos = Vector2()
var shoot_time = 0
var facing_dir = 1
var current_health = 0
var jumped = false

func get_input():
	var x = 0
	var jump = 0
	if Input.is_action_pressed('ui_left'): x += -1
	if Input.is_action_pressed('ui_right'): x += 1
	if Input.is_action_just_pressed('ui_up'):
		if is_on_floor():
			jump = 1
			jumped = false
		elif not jumped:
			jump = 1
			emit_signal('Double_Jumped')
			jumped = true
	if x != 0:
		facing_dir = x
		$AnimatedSprite.flip_h = false if x > 0 else true
		$AnimatedSprite.animation = 'run'
	else:
		$AnimatedSprite.animation = 'idle'
	if not is_on_floor():
		$AnimatedSprite.animation = 'jump'
	if jump:
		var dust_node = dust_scene.instance()
		dust_node.position = position + Vector2(0, 16)
		$'..'.add_child(dust_node)
		dust_node.restart()
	return [x, jump]
	
func _ready():
	start_pos = position
	gravity = -2*Jump_Height/Jump_Time/Jump_Time
	jump_velocity = abs(gravity)*Jump_Time
	#print('gravity:', gravity, ' jump velocity:', jump_velocity)

func _process(delta):
	shoot_time -= delta
	if Input.is_action_pressed('ui_accept') and shoot_time < 0:
		shoot_time = Shoot_Interval
		var bullett_node = bullett_scene.instance()
		bullett_node.position = position
		bullett_node.direction = facing_dir
		get_parent().add_child(bullett_node)

func _physics_process(delta):
	var input = get_input()
	var input_x = input[0]
	var jump = input[1]
	var desired_vel_x = input_x*Max_Speed
	var accelerate_dir = sign(desired_vel_x - velocity.x)
	var new_vel_x = clamp(velocity.x + accelerate_dir*Acceleration, -Max_Speed, Max_Speed)
	
	# remove scattering
	if ((velocity.x - desired_vel_x)*(new_vel_x - desired_vel_x) < 0):
		new_vel_x = desired_vel_x
	# snappy
	if (new_vel_x*desired_vel_x < 0):
		new_vel_x = 0

	var new_vel_y = (1-jump)*(velocity.y - gravity*delta) - jump*jump_velocity
	velocity = move_and_slide(Vector2(new_vel_x, new_vel_y), Vector2(0, -1))

func _input(event):
	if (get_node('/root/global').DEBUG and event.is_action_pressed('ui_focus_next')):
		position = start_pos
