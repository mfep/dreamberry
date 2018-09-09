extends Sprite

export(PackedScene) var Seed_Scene

func instantiate_seed():
	var seed_node = Seed_Scene.instance()
	seed_node.position = $SeedPos.position
	add_child(seed_node)
