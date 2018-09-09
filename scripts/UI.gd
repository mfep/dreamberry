extends CanvasLayer

enum PickupType { Pickup, Seed }

export(int) var Enemy_Kill_Score
export(int) var Pickup_Score
export(int) var Double_Jump_Penalty

func update_text(animate = true):
	$ScoreLabel.text = String(int(get_node('/root/global').score))
	if animate:
		$ScoreLabel/AnimationPlayer.play('scored')

func _ready():
	update_text(false)

func _on_enemy_killed():
	get_node('/root/global').score += Enemy_Kill_Score
	update_text()

func _on_Player_Enemy_Overlap(dps):
	get_node('/root/global').score -= dps
	update_text()

func _on_Player_Double_Jumped():
	if Double_Jump_Penalty != 0:
		get_node('/root/global').score -= Double_Jump_Penalty
		update_text()

func _on_Pickup(type):
	if type == Pickup:
		get_node('/root/global').score += Pickup_Score
		update_text()
