extends Node2D

onready var label_pos: Node2D = $Position
onready var small: Label = $Position/Small
onready var big: Label = $Position/Big
onready var despawn_timer: Timer = $DespawnTimer

export var text = "+10"
export var text_color: Color = Color.white
export var rise_speed = 100

func _ready():
	set_color(text_color)
	set_text(text)

func _process(delta):
	label_pos.global_transform.origin.y -= rise_speed * delta; 
	small.modulate.a = despawn_timer.time_left / despawn_timer.wait_time
	big.modulate.a = despawn_timer.time_left / despawn_timer.wait_time

func set_color(color: Color):
	small.modulate = color
	big.modulate = color

func set_text(_text: String):
	small.text = _text
	big.text = _text

func set_big():
	small.hide()
	big.show()

func set_small():
	small.show()
	big.hide()
