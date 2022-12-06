extends Node2D

var projectile = preload("res://objects/Projectile.tscn")

func fire(target: Vector2, speed = null):
	if !is_visible_in_tree():
		return
	var projectile_inst = projectile.instance()
	get_tree().get_root().add_child(projectile_inst)
	projectile_inst.global_position = global_position
	projectile_inst.set_target(target)
	if speed:
		projectile_inst.set_speed(speed)
