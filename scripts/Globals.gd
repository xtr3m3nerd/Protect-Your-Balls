extends Node

var high_score_file: ConfigFile
var high_score = 0;
var score = 0;

func _ready():
	load_highscore()

func inactivate_shape():
	emit_signal("inact_shape")

func restart_game():
	print("restart_game")
	save_high_score()
	var err = get_tree().reload_current_scene()
	if err:
		print("Failed to restart scene: ", err)

func load_highscore():
	high_score_file = ConfigFile.new()
	var err = high_score_file.load("user://highscore.cfg")
	if err == OK:
		get_highscore()

func get_highscore():
	high_score = high_score_file.get_value("User", "HighScore", high_score)
	set_high_score(high_score)

func save_high_score():
	var err = high_score_file.save("user://highscore.cfg")
	if err:
		print("Failed save highscore: ", err)

func set_high_score(_score):
	high_score = _score
	high_score_file.set_value("User", "HighScore", _score)

func update_score(_score):
	score = _score
	if score > high_score:
		set_high_score(score)
		save_high_score()

