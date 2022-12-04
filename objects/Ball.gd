extends RigidBody2D

var group = -1

var radius = 64

func _ready():
	$Hitbox.connect("popped",self,"pop")

func pop():
	queue_free()


func _on_Ball_mouse_entered():
	print("mouse_entered")
	MouseManager.set_hovering(true)


func _on_Ball_mouse_exited():
	print("mouse_exited")
	MouseManager.set_hovering(false)
