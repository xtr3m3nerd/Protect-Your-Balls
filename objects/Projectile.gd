extends KinematicBody2D

var speed = 400

var direction: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO


var warning = preload("res://objects/ProjectileWarning.tscn")
var warning_inst = null

var is_active = false

func _ready():
	pass
	
func _physics_process(delta):
	if not is_active:
		return
	var collision: KinematicCollision2D = move_and_collide(direction * speed * delta)
	if collision != null:
		print(collision)
	if collision:
		var collider = collision.collider
		print("Collide")
		if collider.has_method("pop"):
			collider.pop()
		destroy()

func set_target(_target):
	target = _target
	direction = (target - global_position).normalized()
	spawn_warning()

func destroy():
	# Where to put destroyed effects and other stuff
	speed = 0
	$CollisionShape2D.set_deferred("disabled", true)
	clear_warning()
	queue_free()

func activate():
	is_active = true

func _on_AliveTimer_timeout():
	destroy()

func spawn_warning():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, direction * 10000, [], 32, false, true)
	if result:
		warning_inst = warning.instance()
		get_tree().get_root().add_child(warning_inst)
		warning_inst.global_position = result.position
		warning_inst.look_at(target)
		warning_inst.projectile = self

func clear_warning():
	if warning_inst:
		warning_inst.destroy()
		warning_inst = null
