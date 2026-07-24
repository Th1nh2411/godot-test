extends Control

@onready var play_button: Button = get_node_or_null("%PlayButton")
@onready var quit_button: Button = get_node_or_null("%QuitButton")

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	# Chuyển sang màn chơi Level 1
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_quit_pressed() -> void:
	# Thoát game
	get_tree().quit()
