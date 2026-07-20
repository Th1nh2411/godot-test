extends CharacterBody2D
class_name Player

## Coordinates the player components. Holds shared data (direction, state)
## that components read/write through this instance instead of duplicating.

enum State {
	IDLE,
	RUN,
	JUMP,
	DOUBLE_JUMP,
	FALL,
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement: MovementComponent = $Components/Movement
@onready var animation: AnimationComponent = $Components/Animation
@onready var combat: CombatComponent = $Components/Combat

## Shared state, owned by Player and read by every component.
var direction: float = 0.0
var state: State = State.IDLE


func _physics_process(delta: float) -> void:
	movement.update(delta)
	state = StateMachine.get_state(self)
	animation.update()
	move_and_slide()
