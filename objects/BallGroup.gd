extends Node2D

var id = -1

onready var ball_group = load("res://objects/BallGroup.tscn")
var center_of_mass: Vector2 = Vector2.ZERO
var pull_force = 200.0
var split_force = 100.0

var colors = [Color.red, Color.blue, Color.green, Color.orange, Color.purple]

# Called when the node enters the scene tree for the first time.
func _ready():
	var script = get_script()
	if not script.has_meta("counter"):
		script.set_meta("counter", 0)
	var counter = script.get_meta("counter")
	counter += 1
	id = counter
	script.set_meta("counter", counter)
	modulate = colors[id % colors.size()]

func _physics_process(delta):
	if get_child_count() < 1:
		queue_free()
		return
	
	calculate_center_of_mass()
	# Attempting to group balls around center of mass by applying forces to each ball
	for child in get_children():
		var direction_to_center = (center_of_mass - child.global_position).normalized()
		if child.get_colliding_bodies().size() < 2:
			child.add_central_force(direction_to_center * pull_force * delta)

func calculate_center_of_mass():
	center_of_mass = Vector2.ZERO
	if get_child_count() <= 0:
		return
		
	for child in get_children():
		center_of_mass = center_of_mass + child.global_position
	
	center_of_mass = center_of_mass / get_child_count()

func split(p1: Vector2, p2: Vector2):
	var left_side = []
	var right_side = []
	for child in get_children():
		var left_or_right = find_side(p1, p2, child.global_position)
		if left_or_right == 0:
			var roll = randi() % 2
			if roll == 0:
				left_or_right = -1
			else:
				left_or_right = 1
		
		if left_or_right == 1:
			left_side.append(child)
		if left_or_right == -1:
			right_side.append(child)
	
	if left_side.size() < 1 or right_side.size() < 1:
		return
	
	var normal_dir = Vector2(-(p2.x - p1.x), p2.y - p1.y).normalized()
	var left_side_group = make_new_group(left_side)
	if left_side_group:
		left_side_group.add_force(left_side_group.center_of_mass, normal_dir * split_force * left_side.size())
	var right_side_group = make_new_group(right_side)
	if right_side_group:
		right_side_group.add_force(right_side_group.center_of_mass, -normal_dir * split_force * right_side.size())
	queue_free()

func make_new_group(balls):
	if balls.size() < 1:
		return null
	var ball_group_inst = ball_group.instance()
	get_parent().add_child(ball_group_inst)
	for ball in balls:
		move_child(ball,ball_group_inst)
	ball_group_inst.calculate_center_of_mass()
	return ball_group_inst

func move_child(child,new_parent):
	var location = child.global_position
	remove_child(child)
	new_parent.add_child(child)
	child.global_position = location

func add_force(offset: Vector2, force: Vector2):
	var num_children = get_child_count()
	for child in get_children():
		child.add_force(offset, force/num_children)
	pass

func merge_children(children):
	pass

# returns int code for which side of the line ab c is on. 1 means left, -1 means right, 0 if on line	
func find_side(a: Vector2, b: Vector2, test_point: Vector2):
	# Test Vertical Line
	if b.x - a.x == 0:
		if test_point.x < b.x:
			if b.y > a.y:
				return 1 
			else:
				return -1
		if test_point.x > b.x:
			if b.y > a.y:
				return -1
			else:
				return 1
		return 0
	# Test Horizontal Line
	if b.y - a.y == 0:
		if test_point.y < b.y:
			if b.x > a.x:
				return -1 
			else:
				return 1
		if test_point.y > b.y:
			if b.x > a.x:
				return 1
			else:
				return -1
		return 0
	# Test Sloped Line
	var slope = (b.y - a.y) / (b.x - a.x)
	var yIntercept = a.y - a.x * slope
	var cSolution = (slope * test_point.x) + yIntercept;
	if (slope != 0):
		if test_point.y > cSolution:
			if b.x > a.x:
				return 1 
			else:
				return -1
		if test_point.y < cSolution:
			if b.x > a.x:
				return -1 
			else:
				return 1
		return 0
	return 0
