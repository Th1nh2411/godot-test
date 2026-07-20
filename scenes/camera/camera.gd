extends Node2D

@export var player: CharacterBody2D

func _physics_process(delta):
	if player:
		global_position.x = player.global_position.x
