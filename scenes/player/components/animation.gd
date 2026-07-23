extends Node
class_name AnimationComponent

## Handles sprite flipping and animation playback only.
## Reads direction/state from the Player; never mutates gameplay data.

@onready var player: Player = owner


func update() -> void:
	_flip()
	_play_state_animation()


func _flip() -> void:
	# Giữ nguyên hướng cuối cùng nếu đang đứng im
	if player.direction != 0:
		# Lật hình ảnh
		player.anim.flip_h = player.direction < 0
		# Lật Hitbox bằng Scale thay vì Position
		var hitbox = player.get_node("Hitbox")
		if player.direction < 0:
			hitbox.scale.x = -1 # Lật ngược toàn bộ Hitbox
		else:
			hitbox.scale.x = 1



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
		Player.State.ATTACK:
			_play("attack")
		Player.State.APPEAR:
			_play("appear")
		Player.State.HIT:
			_play("hit")
		Player.State.DIE:
			_play("die")
		Player.State.DASH:
			_play("dash")
		Player.State.WALL_SLIDE:
			_play("wall_slide")


func _play(name: String) -> void:
	if player.anim.animation != name:
		player.anim.play(name)
