extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Buttons/StartButton.grab_focus()
	if OS.get_name() == "HTML5":
		$Buttons/QuitButton.hide()
	MusicManager.play_music(MusicManager.MUSIC.MENU)
	
	$Scores/BestTime/Time.text = Globals.sec2mmss(Globals.best_time)
	$Scores/BestTime/Points.text = str(Globals.best_time_score).pad_zeros(6)
	
	$Scores/BestScore/Time.text = Globals.sec2mmss(Globals.best_score_time)
	$Scores/BestScore/Points.text = str(Globals.best_score).pad_zeros(6)


func _on_quit_button_pressed():
	GameManager.quit_game()


func _on_button_pressed():
	UiSoundManager.play_button()
