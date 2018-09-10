extends CanvasLayer

export(int) var Enemy_Kill_Score
export(int) var Pickup_Score
export(int) var Double_Jump_Penalty

func update_text(new_score, animate = true):
	$ScoreLabel.text = String(int(new_score))
	if animate:
		$ScoreLabel/AnimationPlayer.play('scored')

func _ready():
	get_node('/root/Game').connect('Score_Changed', self, '_on_Score_Changed')
	update_text(false)

func _on_Score_Changed(new_score):
	update_text(new_score)
