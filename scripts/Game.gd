extends Node

enum Status { GoDream, CanPlant, HasSeedNotEnoughScore }
const QuickSeed = 1
const BlurredSeed = 2
const SaturationSeed = 4

signal Score_Changed(new_score)
signal Picked_Seeds_Changed(seeds)

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
		var seed_node = $'/root/TreesSeeds'.Seeds[picked_seed_index - 1].instance()
		seed_node.get_node('Area2D').monitoring = false
		seed_node.scale *= 0.75
		current_state_node.get_node('Player/SeedPos').add_child(seed_node)
	update_label()
	add_child(current_state_node)
	get_tree().paused = false
	emit_signal('Picked_Seeds_Changed', picked_seeds)

func reload_main():
	current_state_node = main_scene.instance()
	var mask = 0
	for seed_idx in picked_seeds:
		if seed_idx:
			mask |= 1 << (seed_idx - 1)
	apply_seed_effects(mask)
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
				var seed_node = $'/root/TreesSeeds'.Seeds[picked_seed_index-1].instance()
				seed_node.position = current_state_node.get_node('Player').position + Vector2(0, -64)
				current_state_node.add_child(seed_node)
				picked_seed_index = 0
			CanPlant:
				var result = current_state_node.get_node('TreeSpawner').plant_tree(picked_seed_index)
				if result:
					trees.append(result)
					current_state_node.get_node('Player/SeedPos').get_child(0).queue_free()
					_score -= Tree_Costs[picked_seed_index - 1]
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
		picked_seed_index = type
		get_tree().paused = true
		$Timer.wait_time = 1
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
	var tween = current_state_node.get_node('Modulate/Tween')
	tween.interpolate_property(current_state_node.get_node('Modulate'), 'color', Color(1, 1, 1), Color(0, 0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	current_state_node.get_node('UI/AnimationPlayer').play('start')
	update_seed_description_label(current_state_node.get_node('UI/Container/Explanation1'), picked_seeds[0])
	update_seed_description_label(current_state_node.get_node('UI/Container/Explanation2'), picked_seeds[1])
	get_tree().paused = true
	$Timer.wait_time = 5
	$Timer.start()

func apply_seed_effects(mask):
	if mask & QuickSeed:
		current_state_node.get_node('Player').Acceleration *= 2
		current_state_node.get_node('Player').Max_Speed *= 1.6
	if mask & BlurredSeed:
		current_state_node.get_node('UI/BlurPostProc').visible = true
	if mask & SaturationSeed:
		current_state_node.get_node('UI/SaturationPostProc').visible = true

func get_status():
	if picked_seed_index == 0: return GoDream
	if Tree_Costs[picked_seed_index-1] >= _score: return HasSeedNotEnoughScore
	return CanPlant

func update_label():
	var string
	match get_status():
		GoDream: string = 'pick berries. then press \'Space\' to dream'
		HasSeedNotEnoughScore: string = 'press \'Space\' to drop berry. not enough score to plant)'
		CanPlant: string = 'press \'Space\' to plant tree' # TODO tree names
	current_state_node.get_node('UI/Label').text = string

func update_seed_description_label(label, seed_idx):
	var text;
	match seed_idx:
		0: text = ''
		1: text = 'quick movement'
		2: text = 'blurred vision'
		_: assert(false)
	label.text = text
