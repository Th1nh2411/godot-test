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
	ATTACK
}
var is_attacking: bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement: MovementComponent = $Components/Movement
@onready var animation: AnimationComponent = $Components/Animation
@onready var combat: CombatComponent = $Components/Combat
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

## Shared state, owned by Player and read by every component.
var direction: float = 0.0
var state: State = State.IDLE

func _ready() -> void:
	# Bắt sự kiện khi animation chạy xong để kết thúc trạng thái tấn công
	anim.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
		hitbox_collision.disabled = true # Chém xong thì tắt vùng sát thương đi

func _physics_process(delta: float) -> void:
	movement.update(delta)
	state = StateMachine.get_state(self)
	animation.update()
	move_and_slide()
