class_name StateMachine

## Derives the current state purely from Player data (velocity, floor, direction).
## No side effects — add DOUBLE_JUMP / WALL_JUMP / HIT / DASH branches here later.

static func get_state(player: Player) -> Player.State:
	if player.is_attacking:
		return Player.State.ATTACK

	if not player.is_on_floor():
		if player.velocity.y < 0:
			if player.movement.jump_count > 1:
				return Player.State.DOUBLE_JUMP
			return Player.State.JUMP
		return Player.State.FALL

	if player.direction != 0:
		return Player.State.RUN

	return Player.State.IDLE
