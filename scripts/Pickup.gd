extends Node

signal Picked

func _on_Area2D_body_entered(body):
	if body.name == 'Player':
		emit_signal('Picked')
		queue_free()
