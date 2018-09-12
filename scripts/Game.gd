extends Node

enum Status { GoDream, CanPlant, HasSeedNotEnoughScore }
const QuickSeed = 1
const BlurredSeed = 2
const SaturationSeed = 4

signal Score_Changed(new_score)
signal Picked_Seeds_Changed(seeds)

export(Array, int) var Tree_Costs
export(Array, int) var Initial_Seeds = [0, 0]
export(int) var Enemy_Kill_Score
export(int) var Pickup_Score
export(int) var Double_Jump_Penalty

var main_scene = preload('res://scenes/MainScene.tscn')
var garden_scene = preload('res://scenes/GardenScene.tscn')
var scored_label_scene = preload('res://scenes/ScoredLabel.tscn')

var current_state_node = null
var picked_seed_index = 0
var picked_seeds = [0, 0]
var score setget set_score, get_score
var trees = []

var _score = 0

func mod_score(diff):
	set_score(_score + diff)

func set_score(value):
	var prev_score = _score
	_score = max(0, value)
	var player_pos = current_state_node.get_node('Player').position
	if prev_score != _score:
		var score_node = scored_label_scene.instance()
		score_node.position = player_pos
		score_node.score = _score - prev_score
		current_state_node.add_child(score_node)
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

func calculate_seed_mask():
	var mask = 0
	for seed_idx in picked_seeds:
		if seed_idx:
			mask |= 1 << (seed_idx - 1)
	return mask

func reload_main():
	current_state_node = main_scene.instance()
	var mask = calculate_seed_mask()
	apply_seed_effects(mask)
	picked_seeds = [0, 0]
	picked_seed_index = 0
	add_child(current_state_node)
	get_tree().paused = false

func _ready():
	if Initial_Seeds:
		picked_seeds = Initial_Seeds
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
					mod_score(-Tree_Costs[picked_seed_index - 1])
					picked_seed_index = 0
		update_label()

func _on_Seed_Picked(type):
	if type == 0:
		mod_score(Pickup_Score)
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
	mod_score(Enemy_Kill_Score)

func _on_Enemy_Player_Overlap(damage):
	mod_score(-damage)

func _on_Player_Double_Jumped():
	if current_state_node.name != 'GardenScene':
		mod_score(-Double_Jump_Penalty)

func _on_Timer_timeout():
	current_state_node.queue_free()
	reload_main() if current_state_node.name == 'GardenScene' else reload_garden()

func start_Timer():
	var tween = current_state_node.get_node('Modulate/Tween')
	tween.interpolate_property(current_state_node.get_node('Modulate'), 'color', Color(1, 1, 1), Color(0, 0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	current_state_node.get_node('UI/AnimationPlayer').play('start')
	update_seed_description_label(current_state_node.get_node('UI/Container/Explanation1'), picked_seeds[0])
	update_seed_description_label(current_state_node.get_node('UI/Container/Explanation2'), picked_seeds[1])
	update_seed_combination_label()
	get_tree().paused = true
	$Timer.wait_time = 3
	$Timer.start()

func apply_seed_effects(mask):
	if mask & QuickSeed:
		current_state_node.get_node('Player').Acceleration *= 2
		current_state_node.get_node('Player').Max_Speed *= 1.6
	if mask & BlurredSeed:
		current_state_node.get_node('UI/BlurPostProc').visible = true
	if mask & SaturationSeed:
		current_state_node.get_node('UI/SaturationPostProc').visible = true

	# combinations
	if mask == QuickSeed | BlurredSeed:
		current_state_node.get_node('Player').Shoot_Interval *= 0.6
	elif mask == QuickSeed | SaturationSeed:
		current_state_node.get_node('Player').Infinite_Jump = true

func get_status():
	if picked_seed_index == 0: return GoDream
	if Tree_Costs[picked_seed_index-1] >= _score: return HasSeedNotEnoughScore
	return CanPlant

func update_label():
	var cost_string = '(-' + String(Tree_Costs[picked_seed_index-1]) + ')'
	var string
	match get_status():
		GoDream: string = 'pick berries. then press \'Space\' to dream'
		HasSeedNotEnoughScore: string = 'press \'Space\' to drop berry. not enough score to plant ' + cost_string
		CanPlant: string = 'press \'Space\' to plant tree ' + cost_string
	current_state_node.get_node('UI/Label').text = string

func update_seed_description_label(label, seed_idx):
	var text;
	match seed_idx:
		1: text = 'quick movement'
		2: text = 'blurred vision'
		3: text = 'saturated vision'
		_: text = '<nothing>'
	label.text = text

func update_seed_combination_label():
	var mask = calculate_seed_mask()
	var text = '<nothing>'
	if mask == QuickSeed | BlurredSeed: text = 'quick shooting'
	elif mask == QuickSeed | SaturationSeed: text = 'unlimited jumps'
	current_state_node.get_node('UI/Container/Explanation3').text = text
