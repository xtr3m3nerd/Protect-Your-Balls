extends Node

var quit_popup: Resource = load("res://menus/QuitPopup.tscn")
var is_quiting = false

var first_spawn = true

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		quit_game()

func quit_game():
	if OS.get_name() == "HTML5":
		return
	if is_quiting:
		return
	is_quiting = true
	if get_tree().get_root().has_node("Level/GUI"):
		get_tree().get_root().get_node("Level/GUI").add_child(quit_popup.instance())
	else:
		get_tree().get_root().add_child(quit_popup.instance())
