extends RigidBody2D

var group = -1

var radius = 64
var glowing = false

var can_merge = true

var point_numbers = preload("res://objects/PointNumbers.tscn")
var explosion = preload("res://objects/Explosions.tscn")

var faces = [
	"res://assets/faces/face1.png",
	"res://assets/faces/face2.png",
	"res://assets/faces/face3.png",
	"res://assets/faces/face4.png",
	"res://assets/faces/face5.png",
	"res://assets/faces/face6.png",
	"res://assets/faces/face7.png",
]

func is_ball():
	return true

func _ready():
	var face_idx = randi() % faces.size()
	$Graphics/Face.texture = load(faces[face_idx])
	var err = $Hitbox.connect("popped", self, "pop")
	if err:
		print("could not connect to hitbox: ", err)

func pop():
	$Graphics.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox.set_deferred("monitoring", false)
	$PopNoise.play()
	spawn_explosion()

func spawn_explosion():
	var explosion_inst = explosion.instance()
	get_tree().get_root().add_child(explosion_inst)
	explosion_inst.global_position = global_position

func _on_Ball_mouse_entered():
	MouseManager.set_hovering(self)
	$Graphics/Glow.show()


func _on_Ball_mouse_exited():
	MouseManager.set_hovering(null)
	if not glowing:
		$Graphics/Glow.hide()

func show_glow():
	glowing = true
	$Graphics/Glow.show()

func hide_glow():
	glowing = false
	$Graphics/Glow.hide()


func _on_PopNoise_finished():
	queue_free()


func _on_Ball_body_entered(body):
	if not can_merge:
		return
	if not body.has_method("is_ball"):
		return
	if get_parent() != body.get_parent():
		if is_instance_valid(get_parent()) and is_instance_valid(body.get_parent()):
			#get_parent().merge_group(body.get_parent())
			start_merge_timer()

func start_merge_timer():
	can_merge = false
	$MergeTimer.start()

func _on_MergeTimer_timeout():
	can_merge = true


func _on_PointsTimer_timeout():
	var points = get_parent().get_child_count()
	Globals.add_points(points)
	spawn_point_numbers(points)

func spawn_point_numbers(ammt):
	var point_numbers_inst = point_numbers.instance()
	#get_tree().get_root().add_child(point_numbers_inst)
	add_child(point_numbers_inst)
	#point_numbers_inst.global_transform.origin = global_transform.origin
	point_numbers_inst.set_text("+" + str(ammt))
