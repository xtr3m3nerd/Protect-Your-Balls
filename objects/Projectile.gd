extends KinematicBody2D

var speed = 400

var direction: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO

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

func destroy():
	# Where to put destroyed effects and other stuff
	speed = 0
	$CollisionShape2D.disabled = true
	queue_free()

func activate():
	is_active = true

func _on_AliveTimer_timeout():
	queue_free()
