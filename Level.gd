extends Node2D

onready var projectile_spawner = $ProjectileSpawner
onready var ball_groups = $BallGroups
onready var time_keeper = $GUI/Timer

var ball = preload("res://objects/Ball.tscn")
var ball_group = preload("res://objects/BallGroup.tscn")


var gameover_screen = preload("res://GameOverScreen.tscn")

var starting_group = null

var starting_num_of_balls = 16

var arrow_spawn_timer: Timer
var arrow_spawn_time_range: Vector2 = Vector2(1.0, 0.1)

var max_rate_timer: Timer
var time_to_max_spawn_rate = 360.0
var max_rate = false

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
	
	err = MouseManager.connect("cut", self, "cut_groups")
	if err:
		print("Failed to connect to mouse manager: ", err)
	
	spawn_balls()

func _physics_process(delta):
	if ball_groups.get_child_count() == 0 and not gameover:
		spawn_gameover_screen()
		
func spawn_gameover_screen():
	gameover = true
	Globals.update_score(time_keeper.time_elapsed)
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
	
	projectile_spawner.global_position = spawner_pos
	projectile_spawner.look_at(target)
	projectile_spawner.fire(target)
	
	var next_rate = arrow_spawn_time_range.x + (arrow_spawn_time_range.y - arrow_spawn_time_range.x) * (1 - max_rate_timer.time_left / max_rate_timer.wait_time)
	if max_rate:
		next_rate = arrow_spawn_time_range.y
	arrow_spawn_timer.wait_time = next_rate
	arrow_spawn_timer.start()

func set_max_rate():
	max_rate = true


func _on_Arena_body_exited(body):
	if body.has_method("destroy"):
		body.destroy()

func cut_groups(p1, p2):
	for group in ball_groups.get_children():
		group.split(p1, p2)


func _on_ProjectileWarningBox_body_entered(body):
	if body.is_active and body.has_method("clear_warning"):
		body.clear_warning()
