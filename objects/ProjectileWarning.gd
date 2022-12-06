extends Node2D


var projectile = null
onready var anim_player = $AnimationPlayer

var playback_speeds = Vector2(5.0, 0.5)
var start_dist = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func destroy():
	if projectile:
		projectile.play_noise()
	queue_free()

func _physics_process(_delta):
	if projectile == null:
		return
	var distance = (projectile.global_position - global_position).length()
	
	if start_dist == -1:
		start_dist = distance
		
	anim_player.playback_speed = lerp(playback_speeds.x, playback_speeds.y, distance/start_dist)
