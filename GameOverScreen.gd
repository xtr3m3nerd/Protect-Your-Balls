extends Control

func _ready():
	$TimeBox/Time.text = msec2mmss(Globals.score)
	$HighScore/Time.text = msec2mmss(Globals.high_score)
	if Globals.score == Globals.high_score:
		$NewHighScore.show()
	else:
		$NewHighScore.hide()

func _input(_event):
	if Input.is_action_pressed("restart"):
		Globals.restart_game()

func msec2mmss(_msecs: int):
	var msec: int = int(_msecs % 1000)
	var seconds: int = int(_msecs / 1000.0) % 60
	var minutes: int = int(_msecs / 60000.0)
	var mmss_string: String = "%d:%02d.%03d" % [minutes, seconds, msec]
	return mmss_string
