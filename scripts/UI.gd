extends CanvasLayer

export(int) var Enemy_Kill_Score

var score = 0

func update_text():
	$ScoreLabel.text = String(score)
	$ScoreLabel/AnimationPlayer.play('scored')

func _on_enemy_killed():
	score += Enemy_Kill_Score
	update_text()

func _on_Player_Health_Changed(new_health):
	$HealthBar.value = new_health / $'../Player'.Max_Health
