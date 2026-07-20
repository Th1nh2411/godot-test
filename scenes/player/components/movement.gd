extends Node
class_name MovementComponent

## Owns input reading, horizontal movement, gravity, jumping and velocity.
## Writes velocity/direction back onto the Player so other components can read them.

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const MAX_JUMPS := 2

@onready var player: Player = owner
var jump_count := 0


func update(delta: float) -> void:
	player.direction = Input.get_axis("ui_left", "ui_right")
	_apply_gravity(delta)
	_handle_jump()
	_handle_horizontal()


func _apply_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	else:
		jump_count = 0


func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		player.velocity.y = JUMP_VELOCITY
		jump_count += 1


func _handle_horizontal() -> void:
	if player.direction != 0:
		player.velocity.x = player.direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
