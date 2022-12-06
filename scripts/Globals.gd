extends Node

signal add_points

var high_score_file: ConfigFile

var time = 0
var score = 0

var best_time = 0
var best_time_score = 0

var best_score = 0
var best_score_time = 0

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
	best_time = high_score_file.get_value("User", "BestTime", best_time)
	best_time_score = high_score_file.get_value("User", "BestTimeScore", best_time_score)
	set_best_time(best_time, best_time_score)
	best_score = high_score_file.get_value("User", "BestScore", best_score)
	best_score_time = high_score_file.get_value("User", "BestScoreTime", best_score_time)
	set_best_score(best_score, best_score_time)

func save_high_score():
	var err = high_score_file.save("user://highscore.cfg")
	if err:
		print("Failed save highscore: ", err)

func set_best_time(_best_time, _best_time_score):
	best_time = _best_time
	high_score_file.set_value("User", "BestTime", best_time)
	best_time_score = _best_time_score
	high_score_file.set_value("User", "BestTimeScore", best_time_score)
	
func set_best_score(_best_score, _best_score_time):
	best_score = _best_score
	high_score_file.set_value("User", "BestScore", _best_score)
	best_score_time = _best_score_time
	high_score_file.set_value("User", "BestScoreTime", _best_score_time)

func add_points(points):
	score += points
	emit_signal("add_points")

func update_time(_time):
	time = _time
	if time > best_time:
		set_best_time(time, score)
	if score > best_score:
		set_best_score(score, time)

func msec2mmss(_msecs: int):
	var msec: int = int(_msecs % 1000)
	var seconds: int = int(_msecs / 1000.0) % 60
	var minutes: int = int(_msecs / 60000.0)
	var mmss_string: String = "%d:%02d.%03d" % [minutes, seconds, msec]
	return mmss_string
	
func sec2mmss(_secs: float):
	var _msecs = int(_secs * 1000)
	return msec2mmss(_msecs)
