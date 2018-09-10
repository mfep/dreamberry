extends Node

enum Status { GoDream, CanPlant, HasSeedNotEnoughScore }

signal Score_Changed(new_score)
signal Picked_Seeds_Changed(seeds)

export(Array) var Seed_Scenes;
export(Array, int) var Tree_Costs
export(int) var Enemy_Kill_Score
export(int) var Pickup_Score
export(int) var Double_Jump_Penalty

var main_scene = preload('res://scenes/MainScene.tscn')
var garden_scene = preload('res://scenes/GardenScene.tscn')

var current_state_node = null
var picked_seed_index = 0
var picked_seeds = [0, 0]
var score setget set_score, get_score
var trees = []

var _score = 0

func set_score(value):
	_score = value
	emit_signal('Score_Changed', _score)

func get_score():
	return _score

func reload_garden():
	current_state_node = garden_scene.instance()
	if picked_seed_index != 0:
		var seed_node = Seed_Scenes[picked_seed_index - 1].instance()
		seed_node.get_node('Area2D').monitoring = false
		seed_node.scale *= 0.75
		current_state_node.get_node('Player/SeedPos').add_child(seed_node)
	update_label()
	add_child(current_state_node)
	get_tree().paused = false
	emit_signal('Picked_Seeds_Changed', picked_seeds)

func reload_main():
	current_state_node = main_scene.instance()
	apply_seed_effects(picked_seeds[0])
	apply_seed_effects(picked_seeds[1])
	picked_seeds = [0, 0]
	picked_seed_index = 0
	add_child(current_state_node)
	get_tree().paused = false

func _ready():
	reload_garden()

func _input(event):
	if event.is_action_released('ui_accept') and current_state_node.name == 'GardenScene' and $Timer.is_stopped():
		match get_status():
			GoDream:
				start_Timer()
			HasSeedNotEnoughScore:
				current_state_node.get_node('Player/SeedPos').get_child(0).queue_free()
				var seed_node = Seed_Scenes[picked_seed_index-1].instance()
				seed_node.position = current_state_node.get_node('Player').position + Vector2(0, -64)
				current_state_node.add_child(seed_node)
				picked_seed_index = 0
			CanPlant:
				var result = current_state_node.get_node('TreeSpawner').plant_tree(picked_seed_index)
				if result:
					trees.append(result)
					current_state_node.get_node('Player/SeedPos').get_child(0).queue_free()
					picked_seed_index = 0
		update_label()

func _on_Seed_Picked(type):
	if type == 0:
		_score += Pickup_Score
		emit_signal('Score_Changed', _score)
	elif current_state_node.name == 'GardenScene':
		picked_seeds.push_front(type)
		picked_seeds.pop_back()
		emit_signal('Picked_Seeds_Changed', picked_seeds)
	else:
		get_tree().paused = true
		$Timer.start()

func _on_Enemy_Killed():
	_score += Enemy_Kill_Score
	emit_signal('Score_Changed', _score)

func _on_Enemy_Player_Overlap(damage):
	_score -= damage
	emit_signal('Score_Changed', _score)

func _on_Player_Double_Jumped():
	if current_state_node.name != 'GardenScene':
		_score -= Double_Jump_Penalty
		emit_signal('Score_Changed', _score)

func _on_Timer_timeout():
	_score = max(0, _score)
	current_state_node.queue_free()
	reload_main() if current_state_node.name == 'GardenScene' else reload_garden()

func start_Timer():
	get_tree().paused = true
	$Timer.start()

func apply_seed_effects(index):
	match index:
		0: pass
		1: # quick movement seed
			current_state_node.get_node('Player').Acceleration *= 2
			current_state_node.get_node('Player').Max_Speed *= 1.6
		2: # blurred
			current_state_node.get_node('UI/BlurPostProc').visible = true
		3: # saturated
			current_state_node.get_node('UI/SaturationPostProc').visible = true
		4: # former health TODO
			print('WARNING: Seed4 not implemented!')
		5: # former health TODO
			print('WARNING: Seed5 not implemented!')
		_: assert(false)

func get_status():
	if picked_seed_index == 0: return GoDream
	if Tree_Costs[picked_seed_index-1] >= _score: return HasSeedNotEnoughScore
	return CanPlant

func update_label():
	var string
	match get_status():
		GoDream: string = 'press \'Space\' to dream'
		HasSeedNotEnoughScore: string = 'press \'Space\' to drop seed: not enough score to plant)'
		CanPlant: string = 'press \'Space\' to plant tree' # TODO tree names
	current_state_node.get_node('UI/Label').text = string
