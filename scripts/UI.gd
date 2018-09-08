extends CanvasLayer

export(int) var Enemy_Kill_Score
export(int) var Double_Jump_Penalty

var score = 0

func update_text():
	$ScoreLabel.text = String(int(score))
	$ScoreLabel/AnimationPlayer.play('scored')

func _on_enemy_killed():
	score += Enemy_Kill_Score
	update_text()

func _on_Player_Enemy_Overlap(dps):
	score -= dps
	update_text()

func _on_Player_Double_Jumped():
	score -= Double_Jump_Penalty
	update_text()
