extends Node

var main_scene = preload('res://scenes/MainScene.tscn')

var main_node = null

func reload_main():
	main_node = main_scene.instance()
	main_node.get_node('Spawner').connect('All_Spawned', self, '_on_Spawner_All_Spawned')
	add_child(main_node)
	get_tree().paused = false

func _ready():
	reload_main()

func _on_Spawner_All_Spawned(seed_node):
	seed_node.connect('Picked', self, '_on_Seed_Picked')

func _on_Seed_Picked(type):
	assert(type == 1)
	get_tree().paused = true
	$Timer.start()

func _on_Timer_timeout():
	main_node.queue_free()
	reload_main()
