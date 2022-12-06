extends Node2D

onready var line = $Line2D

signal cut(p1, p2)

var pressed = false
var start_location: Vector2 = Vector2.ZERO
var end_location: Vector2 = Vector2.ZERO

var cut_icon = load("res://assets/ScissorIcon.png")
var grab_icon = load("res://assets/HandIcon.png")
var dotted_texture = load("res://assets/DottedLine.png")

var is_hovering = false
var hovering_ball = null
var grabbed_ball = null
var grabbed_group = null
var is_cutting

var min_dist = 100.0

var max_dist = 1000.0
var pitch_range = Vector2(1.0, 4.0)

var pull_force = 5.0

func _ready():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	#Input.set_custom_mouse_cursor(cut_icon)
	line.hide()

func _physics_process(delta):
	
	if (Input.is_action_pressed("grab") or Input.is_action_pressed("cut")) and pressed:
		
		if not is_cutting:
			if (not is_instance_valid(grabbed_ball) or not is_instance_valid(grabbed_group)):
				cancel_press()
		
		end_location = get_global_mouse_position()
		if grabbed_ball != null:
			start_location = grabbed_ball.global_position
		var line_points = PoolVector2Array([start_location, end_location])
		line.points = line_points
		var line_vec = end_location - start_location
		if grabbed_ball != null and grabbed_group != null:
			#grabbed_group.add_force(start_location, line_vec * pull_force * delta)
			grabbed_group.apply_central_impulse(line_vec * pull_force * delta)
		var dist = (end_location-start_location).length()
		$SelectedNoise.pitch_scale = lerp(pitch_range.x, pitch_range.y, clamp(dist, 0.0, max_dist)/max_dist)
		
	elif pressed: 
		var dist = (end_location - start_location).length()
		if is_cutting and dist > min_dist:
			emit_signal("cut", start_location, end_location)
		
		if not is_instance_valid(hovering_ball):
			hovering_ball = check_under_mouse()
		
		if is_instance_valid(grabbed_group) and hovering_ball != null:
			grabbed_group.merge_group(hovering_ball.get_parent())
			
		cancel_press()
 
func _input(event):
	if event.is_action_pressed("grab"):
		if pressed:
			cancel_press()
		else:
			if not is_instance_valid(hovering_ball):
				hovering_ball = check_under_mouse()
				if hovering_ball == null:
					return
					
			pressed = true
			$SelectNoise.play()
			$SelectedNoise.play()
			start_location = get_global_mouse_position()
			line.show()
			grabbed_ball = hovering_ball
			grabbed_group = grabbed_ball.get_parent()
			grabbed_group.show_glow()
	
	if event.is_action_pressed("cut"):
		if pressed:
			cancel_press()
		else:
			pressed = true
			$SelectNoise.play()
			is_cutting = true
			start_location = get_global_mouse_position()
			line.show()
			line.texture = dotted_texture

func check_under_mouse():
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_point(get_global_mouse_position(), 32, [], 64, false, true)
	if results.size() > 0:
		return results[0].collider.get_parent()
	else:
		return null

func cancel_press():
	pressed = false
	is_cutting = false
	$DeselectNoise.play()
	$SelectedNoise.stop()
	set_icon()
	line.hide()
	line.texture = null
	
	if is_instance_valid(grabbed_group):
		grabbed_group.hide_glow()
		grabbed_group = null
	
	grabbed_ball = null
	grabbed_group = null
		
	start_location = Vector2.ZERO
	end_location = Vector2.ZERO
	

func set_hovering(ball = null):
	hovering_ball = ball
	is_hovering = ball != null
	if not pressed:
		set_icon()

func set_icon():
	if is_hovering:
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		#Input.set_custom_mouse_cursor(grab_icon)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		#Input.set_custom_mouse_cursor(cut_icon)

