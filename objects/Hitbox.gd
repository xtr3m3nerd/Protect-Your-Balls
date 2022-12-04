extends Area2D

signal popped()

func pop(body = null):
	print("pop: ", body)
	if body and body.is_active:
		print("projectile: ", body.global_position, " pos: ", global_position)
		body.destroy()
		emit_signal("popped")

