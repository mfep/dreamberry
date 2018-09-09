extends Node

signal Score_Changed(new_score)

var DEBUG = false
var score setget set_score, get_score
var trees = []

var _score = 0

func set_score(value):
	_score = value
	emit_signal('Score_Changed', _score)
	
func get_score():
	return _score
