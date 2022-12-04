extends Label

var time_start = 0
var time_now = 0
var time_elapsed = 0

func _ready():
	time_start = OS.get_ticks_msec()
	
func _process(_delta):
	time_now = OS.get_ticks_msec()
	time_elapsed = time_now - time_start
	text = msec2mmss(time_elapsed)
	
func msec2mmss(_msecs: int):
	var msec: int = int(_msecs % 1000)
	var seconds: int = int(_msecs / 1000.0) % 60
	var minutes: int = int(_msecs / 60000.0)
	var mmss_string: String = "%d:%02d.%03d" % [minutes, seconds, msec]
	return mmss_string
