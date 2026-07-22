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
	ATTACK,
	APPEAR,
	DIE,
	HIT
}
var is_attacking: bool = false
var is_appearing: bool = true
var is_dead: bool = false
var is_hit: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement: MovementComponent = $Components/Movement
@onready var animation: AnimationComponent = $Components/Animation
@onready var combat: CombatComponent = $Components/Combat
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

@onready var health_bar: ProgressBar = get_node_or_null("HUD/HealthBar")

## Shared state, owned by Player and read by every component.
var direction: float = 0.0
var state: State = State.IDLE

func _ready() -> void:
	# Bắt sự kiện khi animation chạy xong để kết thúc trạng thái
	anim.animation_finished.connect(_on_animation_finished)
	# Bắt sự kiện hết máu
	combat.died.connect(_on_died)
	
	# Khởi tạo thanh máu nếu đã vẽ UI
	if health_bar:
		health_bar.max_value = combat.max_hp
		health_bar.value = combat.hp
		combat.hp_changed.connect(_on_hp_changed)

func _on_hp_changed(current_hp: int, max_hp: int) -> void:
	# Bị mất máu -> Chuyển sang trạng thái HIT (Stun)
	if current_hp < combat.max_hp: 
		is_hit = true
		# Cài đặt đồng hồ đúng 0.5 giây sau thì hết choáng
		get_tree().create_timer(0.5).timeout.connect(func(): if not is_dead: is_hit = false)
		
	if health_bar:
		health_bar.value = current_hp

func _on_died() -> void:
	is_dead = true

func _on_animation_finished() -> void:
	if anim.animation == "appear":
		is_appearing = false
	elif anim.animation == "attack":
		is_attacking = false
		hitbox_collision.disabled = true # Chém xong thì tắt vùng sát thương đi
	elif anim.animation == "die":
		# Game Over! Tạm thời xóa Player khỏi màn hình
		queue_free()

func _physics_process(delta: float) -> void:
	# Nếu đang xuất hiện, bị đánh hoặc đã chết thì KHÔNG cho phép di chuyển (Bị choáng)
	if is_appearing or is_dead or is_hit:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
	else:
		movement.update(delta)
		
	state = StateMachine.get_state(self)
	animation.update()
	move_and_slide()
