extends Node2D

onready var line = $Line2D

signal cut(p1, p2)

var pressed = false
var start_location: Vector2 = Vector2.ZERO
var end_location: Vector2 = Vector2.ZERO

var cut_icon = load("res://assets/ScissorIcon.png")
var grab_icon = load("res://assets/HandIcon.png")

var is_hovering = false
var hovering_ball = null
var grabbed_ball = null
var is_cutting

var min_dist = 100.0

var pull_force = 5.0

func _ready():
	Input.set_custom_mouse_cursor(cut_icon)
	line.hide()

func _physics_process(delta):
	if not is_instance_valid(grabbed_ball):
		grabbed_ball = null
	if Input.is_action_pressed("click") and pressed:
		end_location = get_global_mouse_position()
		if grabbed_ball != null:
			start_location = grabbed_ball.global_position
		var line_points = PoolVector2Array([start_location, end_location])
		line.points = line_points
		var line_vec = end_location - start_location
		if grabbed_ball != null:
			grabbed_ball.get_parent().add_force(start_location, line_vec * pull_force * delta)
	elif pressed: 
		pressed = false 
		var dist = (end_location - start_location).length()
		if is_cutting and dist > min_dist:
			emit_signal("cut", start_location, end_location)
		start_location = Vector2.ZERO
		end_location = Vector2.ZERO
		grabbed_ball = false
		set_icon()
		line.hide()
 
func _input(event):
	if event.is_action_pressed("click"):
		pressed = true
		start_location = get_global_mouse_position()
		line.show()
		grabbed_ball = hovering_ball
		is_cutting = hovering_ball == null
	
	if event.is_action_pressed("cancel"):
		pressed = false
		set_icon()
		line.hide()

func set_hovering(ball = null):
	hovering_ball = ball
	is_hovering = ball != null
	if not pressed:
		set_icon()

func set_icon():
	if is_hovering:
		Input.set_custom_mouse_cursor(grab_icon)
	else:
		Input.set_custom_mouse_cursor(cut_icon)

