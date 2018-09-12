extends Node2D

export(Color) var Positive_Color
export(Color) var Negative_Color
export(float) var Tween_Time

var score setget set_score

func set_score(value):
	var _text = '+ ' if value >= 0 else '- '
	$Label.add_color_override('font_color_shadow', Positive_Color if value >= 0 else Negative_Color)
	_text += String(abs(value))
	$Label.text = _text
	
	$Tween.interpolate_property($Label, 'margin_top', $Label.margin_top, $Label.margin_top - 100, Tween_Time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0), Tween_Time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func _on_Timer_timeout():
	queue_free()
