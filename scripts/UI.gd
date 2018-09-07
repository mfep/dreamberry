extends CanvasLayer

func _on_Player_Health_Changed(new_health):
	$ProgressBar.value = new_health / $'../Player'.Max_Health
