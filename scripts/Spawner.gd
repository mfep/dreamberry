extends Node

export(int) var Number_Enemies
export(int) var Number_Pickups

var enemy_scene = preload('res://scenes/Enemy.tscn')
var pickup_scene = preload('res://scenes/Pickup.tscn')

func _on_TileMap_Map_generated(spawn_points, top_pos):
	# clear
	for child in get_children():
		child.queue_free()
	var points = spawn_points.duplicate()

	# spawn pickups
	for i in range(Number_Pickups):
		var pickup_node = pickup_scene.instance()
		var index = randi() % points.size()
		pickup_node.position = points[index]
		points.remove(index)
		add_child(pickup_node)

	# spawn enemies
	for i in range(Number_Enemies):
		var enemy_node = enemy_scene.instance()
		enemy_node.position = spawn_points[randi(spawn_points) % spawn_points.size()]
		add_child(enemy_node)

	# spawn seed
	var seed_node = $'/root/TreesSeeds'.get_random_seed().instance()
	seed_node.position = top_pos
	add_child(seed_node)
