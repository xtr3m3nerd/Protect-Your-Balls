extends Label

var time_elapsed = 0

func _ready():
	time_elapsed = 0
	
func _process(delta):
	time_elapsed += delta
	text = Globals.sec2mmss(time_elapsed)
