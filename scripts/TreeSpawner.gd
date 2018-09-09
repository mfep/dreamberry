extends Node

export(int) var Number_Trees
export(Color) var Tree_Modulate
export(bool) var Load_Saved_Trees = false

var tree_scene =  preload('res://scenes/Tree1.tscn')

func generate_trees(spawn_points):
	var points = spawn_points.duplicate()
	for i in range(Number_Trees):
		var tree_node = tree_scene.instance()
		var point_idx = randi() % points.size()
		tree_node.position = spawn_points[point_idx] + Vector2(0, 16)
		tree_node.modulate = Tree_Modulate
		var scale = 1+randi()%2
		tree_node.scale = Vector2(scale, scale)
		tree_node.flip_h = randi() % 2
		points.remove(point_idx)
		add_child(tree_node)

func load_trees():
	var tree_data_array = get_node('/root/global').trees
	for tree_data in tree_data_array:
		var tree_node = tree_scene.instance()
		tree_node.position = tree_data['position']
		tree_node.flip_h = tree_data['flip']
		tree_node.scale = tree_data['scale']
		tree_node.modulate = Tree_Modulate
		add_child(tree_node)

func _on_TileMap_Map_generated(spawn_points, top_pos):
	if Load_Saved_Trees:
		load_trees()
	else:
		generate_trees(spawn_points)
