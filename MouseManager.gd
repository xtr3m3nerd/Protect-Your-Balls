extends Node2D

onready var line = $Line2D

var pressed = false
var start_location: Vector2 = Vector2.ZERO
var end_location: Vector2 = Vector2.ZERO

var cut_icon = load("res://assets/ScissorIcon.png")
var grab_icon = load("res://assets/HandIcon.png")

var is_hovering = false

func _ready():
	Input.set_custom_mouse_cursor(cut_icon)
	line.hide()

func _process(delta):
	if Input.is_action_pressed("click"):
		end_location = get_global_mouse_position()
		var line_points = PoolVector2Array([start_location, end_location])
		line.points = line_points
	else: 
		pressed = false 
		start_location = Vector2.ZERO
		end_location = Vector2.ZERO
		line.hide()
 
func _input(event):
	if event.is_action_pressed("click"):
		pressed = true
		start_location = get_global_mouse_position()
		line.show()

func set_hovering(hovering):
	is_hovering = hovering
	if is_hovering:
		Input.set_custom_mouse_cursor(cut_icon)
	else:
		Input.set_custom_mouse_cursor(grab_icon)
