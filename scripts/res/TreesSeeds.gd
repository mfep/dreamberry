extends Node

var Trees = [
	preload('res://scenes/trees/Tree1.tscn'),
	preload('res://scenes/trees/Tree2.tscn'),
	preload('res://scenes/trees/Tree3.tscn'),
	preload('res://scenes/trees/Tree4.tscn'),
	preload('res://scenes/trees/Tree5.tscn')]

var Seeds = [
	preload('res://scenes/trees/Seed1.tscn'),
	preload('res://scenes/trees/Seed2.tscn'),
	preload('res://scenes/trees/Seed3.tscn'),
	preload('res://scenes/trees/Seed4.tscn'),
	preload('res://scenes/trees/Seed5.tscn')]

func get_random_tree():
	return Trees[randi() % Trees.size()]

func get_random_seed():
	return Seeds[randi() % Seeds.size()]
