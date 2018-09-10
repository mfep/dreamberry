extends CanvasLayer

func update_text(new_score, animate = true):
	$ScoreLabel.text = String(int(new_score))
	if animate:
		$ScoreLabel/AnimationPlayer.play('scored')

func _ready():
	get_node('/root/Game').connect('Score_Changed', self, '_on_Score_Changed')
	update_text($'/root/Game'.score, false)

func _on_Score_Changed(new_score):
	update_text(new_score)
