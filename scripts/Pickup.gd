extends Node2D

enum PickupType { Pickup, Seed1, Seed2, Seed3, Seed4, Seed5 }

export(float) var Hover_Freq
export(float) var Hover_Amplitude
export(PickupType) var Type

signal Picked(type)

var initial_pos;

func _ready():
	initial_pos = position
	connect('Picked', $'/root/Game', '_on_Seed_Picked')

func _process(delta):
	position = initial_pos + Vector2(0, Hover_Amplitude*sin(2*PI*Hover_Freq*OS.get_ticks_msec()/1000))

func _on_Area2D_body_entered(body):
	if body.name == 'Player':
		emit_signal('Picked', Type)
		queue_free()
