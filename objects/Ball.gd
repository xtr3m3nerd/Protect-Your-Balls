extends RigidBody2D

var group = -1

var radius = 64

func _ready():
	var err = $Hitbox.connect("popped",self,"pop")
	if err:
		print("could not connect to hitbox: ", err)

func pop():
	queue_free()


func _on_Ball_mouse_entered():
	MouseManager.set_hovering(self)


func _on_Ball_mouse_exited():
	MouseManager.set_hovering(null)
