extends Node

var main_scene = preload('res://scenes/MainScene.tscn')
var garden_scene = preload('res://scenes/GardenScene.tscn')

var current_state_node = null

func reload_garden():
	current_state_node = garden_scene.instance()
	current_state_node.get_node('Seed').connect('Picked', self, '_on_Seed_Picked')
	add_child(current_state_node)
	get_tree().paused = false

func reload_main():
	current_state_node = main_scene.instance()
	current_state_node.get_node('Spawner').connect('All_Spawned', self, '_on_Spawner_All_Spawned')
	add_child(current_state_node)
	get_tree().paused = false

func _ready():
	reload_garden()

func _on_Spawner_All_Spawned(seed_node):
	seed_node.connect('Picked', self, '_on_Seed_Picked')

func _on_Seed_Picked(type):
	assert(type == 1)
	get_tree().paused = true
	$Timer.start()

func _on_Timer_timeout():
	get_node('/root/global').score = max(0, get_node('/root/global').score)
	current_state_node.queue_free()
	reload_main() if current_state_node.name == 'GardenScene' else reload_garden()
