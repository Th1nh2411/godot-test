extends Node
class_name AnimationComponent

## Handles sprite flipping and animation playback only.
## Reads direction/state from the Player; never mutates gameplay data.

@onready var player: Player = owner


func update() -> void:
	_flip()
	_play_state_animation()


func _flip() -> void:
	# Keep last facing when idle: only flip while actually moving.
	if player.direction != 0:
		player.anim.flip_h = player.direction < 0


func _play_state_animation() -> void:
	match player.state:
		Player.State.IDLE:
			_play("idle")
		Player.State.RUN:
			_play("run")
		Player.State.JUMP:
			_play("jump")
		Player.State.DOUBLE_JUMP:
			_play("double_jump")
		Player.State.FALL:
			_play("fall")


func _play(name: String) -> void:
	if player.anim.animation != name:
		player.anim.play(name)
