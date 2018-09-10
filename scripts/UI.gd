extends CanvasLayer

enum PickupType { Pickup, Seed }

export(int) var Enemy_Kill_Score
export(int) var Pickup_Score
export(int) var Double_Jump_Penalty

func update_text(animate = true):
	$ScoreLabel.text = String(int(get_node('/root/Game').score))
	if animate:
		$ScoreLabel/AnimationPlayer.play('scored')

func _ready():
	get_node('/root/Game').connect('Score_Changed', self, '_on_Score_Changed')
	update_text(false)

func _on_enemy_killed():
	get_node('/root/Game').score += Enemy_Kill_Score

func _on_Player_Enemy_Overlap(dps):
	get_node('/root/Game').score -= dps

func _on_Player_Double_Jumped():
	if Double_Jump_Penalty != 0:
		get_node('/root/Game').score -= Double_Jump_Penalty

func _on_Pickup(type):
	if type == Pickup:
		get_node('/root/Game').score += Pickup_Score

func _on_Score_Changed(new_score):
	update_text()
