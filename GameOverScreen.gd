extends Control

func _ready():
	Globals.save_high_score()
	$Scores/ScoreBox/Time.text = Globals.sec2mmss(Globals.time)
	$Scores/ScoreBox/Points.text = str(Globals.score).pad_zeros(6)
	
	$Scores/BestTime/Time.text = Globals.sec2mmss(Globals.best_time)
	$Scores/BestTime/Points.text = str(Globals.best_time_score).pad_zeros(6)
	
	$Scores/BestScore/Time.text = Globals.sec2mmss(Globals.best_score_time)
	$Scores/BestScore/Points.text = str(Globals.best_score).pad_zeros(6)
	
	$NewHighScore.hide()
	if Globals.score == Globals.best_score:
		$NewHighScore.show()
		$Scores/ScoreBox/Points.modulate = Color("fcbc4e")
		
	if Globals.time == Globals.best_time:
		$NewHighScore.show()
		$Scores/ScoreBox/Time.modulate = Color("fcbc4e")
		

func _input(_event):
	if Input.is_action_pressed("restart"):
		Globals.restart_game()
	
	if Input.is_action_pressed("quit"):
		SceneManager.set_current_scene("res://menus/MainMenu.tscn")
