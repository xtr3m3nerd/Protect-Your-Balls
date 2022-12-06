extends Node2D

class_name BallGroup

var id = -1

onready var ball_group = load("res://objects/BallGroup.tscn")
var center_of_mass: Vector2 = Vector2.ZERO
var pull_force = 200.0
var split_force = 1000.0

var colors = [
	Color("fbd0a7"), 
	Color("fab3a2"), 
	Color("fab5c2"), 
	Color("e2b0d1"), 
	Color("b1a6d1"), 
	Color("9fbee0"), 
	Color("96d8ed"), 
	Color("9dd7c9"), 
	Color("baddb6"), 
	Color("efecb6"), 
]

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
		child.apply_central_impulse(direction_to_center * pull_force * delta)
		#if child.get_colliding_bodies().size() < 2:
		#	child.apply_central_impulse(direction_to_center * pull_force * delta)

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
	
	hide_glow()
	
	var normal_dir = Vector2(p2.y - p1.y, -(p2.x - p1.x)).normalized()
	var left_side_group = make_new_group(left_side)
	if left_side_group:
		#left_side_group.add_force(left_side_group.center_of_mass, normal_dir * split_force * left_side.size())
		left_side_group.apply_central_impulse(-normal_dir * split_force * left_side.size())
	var right_side_group = make_new_group(right_side)
	if right_side_group:
		#right_side_group.add_force(right_side_group.center_of_mass, -normal_dir * split_force * right_side.size())
		right_side_group.apply_central_impulse(normal_dir * split_force * right_side.size())
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
	if not is_visible_in_tree():
		return
	if not is_a_parent_of(child):
		return
	child.start_merge_timer()
	var location = child.global_position
	remove_child(child)
	new_parent.add_child(child)
	child.global_position = location

func add_force(offset: Vector2, force: Vector2):
	var num_children = get_child_count()
	for child in get_children():
		child.add_force(offset, force/num_children)

func add_central_force(force: Vector2):
	var num_children = get_child_count()
	for child in get_children():
		child.add_central_force(force/num_children)

func apply_impulse(offset: Vector2, impulse: Vector2):
	var num_children = get_child_count()
	for child in get_children():
		child.apply_impulse(offset, impulse/num_children)

func apply_central_impulse(impulse: Vector2):
	var num_children = get_child_count()
	for child in get_children():
		child.apply_central_impulse(impulse/num_children)

func pop_all():
	for child in get_children():
		child.pop()

func merge_group(group1):
	#if can_merge():
	if group1 == self:
		return
	var merge_group = self
	var doner_group = group1
	if group1.get_child_count() > get_child_count():
		merge_group = group1
		doner_group = self
	
	for ball in doner_group.get_children():
		doner_group.move_child(ball,merge_group)
	merge_group.calculate_center_of_mass()

func can_merge():
	for child in get_children():
		if not child.can_merge:
			return false
	return true

func show_glow():
	for child in get_children():
		child.show_glow()

func hide_glow():
	for child in get_children():
		child.hide_glow()

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
