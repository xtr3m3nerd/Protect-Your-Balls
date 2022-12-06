extends Node2D

onready var projectile_spawner = $ProjectileSpawner
onready var ball_groups = $BallGroups
onready var time_keeper = $GUI/HBoxContainer/Timer

var ball = preload("res://objects/Ball.tscn")
var ball_group = preload("res://objects/BallGroup.tscn")


var gameover_screen = preload("res://GameOverScreen.tscn")

var point_numbers = preload("res://objects/PointNumbers.tscn")

var starting_group = null

var starting_num_of_balls = 16

var arrow_spawn_timer: Timer
var arrow_spawn_time_range: Vector2 = Vector2(5.0, 0.1)

var max_rate_timer: Timer
var time_to_max_spawn_rate = 360.0
var max_rate = false


var max_speed_timer: Timer
var time_to_max_speed = 360.0 * 8
var arrow_speed_range: Vector2 = Vector2(400.0, 1600.0)
var max_speed = false

var fire_radius = 1900.0

var gameover = false


# Called when the node enters the scene tree for the first time.
func _ready():
	arrow_spawn_timer = Timer.new()
	arrow_spawn_timer.wait_time = arrow_spawn_time_range.x
	var err = arrow_spawn_timer.connect("timeout", self, "move_and_fire")
	if err:
		print("Failed to connect to arrow_spawn_timer", err)
	arrow_spawn_timer.one_shot = true
	add_child(arrow_spawn_timer)
	arrow_spawn_timer.start()
	
	max_rate_timer = Timer.new()
	max_rate_timer.wait_time = time_to_max_spawn_rate
	err = max_rate_timer.connect("timeout", self, "set_max_rate")
	if err:
		print("Failed to connect to max_rate_timer", err)
	max_rate_timer.one_shot = true
	add_child(max_rate_timer)
	max_rate_timer.start()
	
	max_speed_timer = Timer.new()
	max_speed_timer.wait_time = time_to_max_speed
	err = max_speed_timer.connect("timeout", self, "set_max_speed")
	if err:
		print("Failed to connect to max_speed_timer", err)
	max_speed_timer.one_shot = true
	add_child(max_speed_timer)
	max_speed_timer.start()
	
	err = MouseManager.connect("cut", self, "cut_groups")
	if err:
		print("Failed to connect to mouse manager: ", err)
	
	spawn_balls()

func _physics_process(_delta):
	if ball_groups.get_child_count() == 0 and not gameover:
		spawn_gameover_screen()

func _input(event):
	if event.is_action_pressed("quit"):
		for group in ball_groups.get_children():
			group.pop_all()
		
func spawn_gameover_screen():
	gameover = true
	Globals.update_time(time_keeper.time_elapsed)
	var gameover_inst = gameover_screen.instance()
	$GUI.add_child(gameover_inst)
	
func spawn_balls():
	starting_group = ball_group.instance()
	ball_groups.add_child(starting_group)
	
	hex_spiral(starting_num_of_balls)

func hex_spiral(num_to_spawn):
	if num_to_spawn <= 0:
		return
	var spawned = 0
	var x = 0
	var y = 0
	spawn_ball(x,y)
	spawned += 1
	if spawned >= num_to_spawn:
		return
	var N = 1
	while true:
		for i in N: # Move Right
			x += 1
			spawn_ball(x,y)
			spawned += 1
			if spawned >= num_to_spawn:
				return
		for i in N-1: # Move Down Right. Note N-1
			y += 1
			spawn_ball(x,y)
			spawned += 1
			if spawned >= num_to_spawn:
				return
		for i in N: # Move down left
			x -= 1
			y += 1
			spawn_ball(x,y)
			spawned += 1
			if spawned >= num_to_spawn:
				return
		for i in N: # Move left
			x -= 1
			spawn_ball(x,y)
			spawned += 1
			if spawned >= num_to_spawn:
				return
		for i in N: # Move up left
			y -= 1
			spawn_ball(x,y)
			spawned += 1
			if spawned >= num_to_spawn:
				return
		for i in N: # Move up right
			x += 1
			y -= 1
			spawn_ball(x,y)
			spawned += 1
			if spawned >= num_to_spawn:
				return

func spawn_ball(x, y):
	var pos = Vector2(float(x) + float(y)/2, 0.8660254037 * float(y))
	var ball_inst = ball.instance()
	starting_group.add_child(ball_inst)
	ball_inst.global_position = pos * ball_inst.radius * 2.0

func move_and_fire():
	var angle = randi() % 360
	var angle_rads = deg2rad(float(angle))
	var direction = Vector2(cos(angle_rads), sin(angle_rads))
	var spawner_pos = direction * fire_radius
	
	var target: Vector2 = Vector2.ZERO
	# Aim at random group
	if ball_groups.get_child_count() > 0:
		var roll = randi() % ball_groups.get_child_count()
		target = ball_groups.get_children()[roll].center_of_mass	
	
	var speed = arrow_speed_range.x + (arrow_speed_range.y - arrow_speed_range.x) * (1 - max_speed_timer.time_left / max_speed_timer.wait_time)
	if max_speed:
		speed = arrow_speed_range.y
		
	projectile_spawner.global_position = spawner_pos
	projectile_spawner.look_at(target)
	projectile_spawner.fire(target, speed)
	
	var next_rate = arrow_spawn_time_range.x + (arrow_spawn_time_range.y - arrow_spawn_time_range.x) * (1 - max_rate_timer.time_left / max_rate_timer.wait_time)
	if max_rate:
		next_rate = arrow_spawn_time_range.y
	arrow_spawn_timer.wait_time = next_rate
	arrow_spawn_timer.start()

func set_max_rate():
	max_rate = true

func set_max_speed():
	max_speed = true

func _on_Arena_body_exited(body):
	if body.has_method("destroy"):
		body.destroy()

func cut_groups(p1, p2):
	for group in ball_groups.get_children():
		group.split(p1, p2)


func _on_ProjectileWarningBox_body_entered(body):
	if body.is_active and body.has_method("clear_warning"):
		body.clear_warning()


func _on_PointsTimer_timeout():
	for group in ball_groups.get_children():
		spawn_point_for_group(group)

func spawn_point_for_group(group):
	var points = group.get_child_count() * group.get_child_count() 
	Globals.add_points(points)
	var point_numbers_inst = point_numbers.instance()
	#get_tree().get_root().add_child(point_numbers_inst)
	add_child(point_numbers_inst)
	point_numbers_inst.global_transform.origin = group.center_of_mass
	point_numbers_inst.set_big()
	point_numbers_inst.set_color(group.modulate)
	point_numbers_inst.set_text("+" + str(points))
