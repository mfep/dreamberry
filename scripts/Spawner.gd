extends Node

export(int) var Number_Enemies

var enemy_scene = preload('res://scenes/Enemy.tscn')

func _on_TileMap_map_generated(spawn_points):
	for child in get_children():
		child.queue_free()
	for i in range(Number_Enemies):
		var enemy_node = enemy_scene.instance()
		enemy_node.connect('Killed', $'../UI', '_on_enemy_killed')
		enemy_node.connect('Player_Overlap', $'../UI', '_on_Player_Enemy_Overlap')
		enemy_node.position = spawn_points[randi(spawn_points) % spawn_points.size()]
		add_child(enemy_node)
