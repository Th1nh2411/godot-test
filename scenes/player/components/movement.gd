extends Node
class_name MovementComponent

## Owns input reading, horizontal movement, gravity, jumping and velocity.
## Writes velocity/direction back onto the Player so other components can read them.

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const MAX_JUMPS := 2
const DASH_SPEED := 800.0
const WALL_SLIDE_SPEED := 100.0
const WALL_JUMP_VELOCITY_X := 100.0

@onready var player: Player = owner
var jump_count := 0
var can_dash := true
var wall_jump_lock := false

func update(delta: float) -> void:
	# Nếu đang lướt, bỏ qua mọi thao tác di chuyển/nhảy khác
	if player.is_dashing:
		_apply_dash_movement()
		return
		
	player.direction = Input.get_axis("move_left", "move_right")
	_handle_dash_input()
	_handle_attack()
	_apply_gravity(delta)
	_handle_jump()
	_handle_horizontal()

func _handle_dash_input() -> void:
	# Phải có nút 'dash' trong Input Map và không đang chém/chờ hồi chiêu
	if Input.is_action_just_pressed("dash") and can_dash and not player.is_attacking:
		player.is_dashing = true
		can_dash = false
		player.combat.is_invincible = true # Bật khiên bất tử
		
		# Lướt theo hướng đang bấm, nếu không bấm thì lướt theo hướng đang quay mặt
		if player.direction != 0:
			player.dash_direction = player.direction
		else:
			# flip_h = false nghĩa là đang quay phải (1.0), ngược lại là trái (-1.0)
			player.dash_direction = -1.0 if player.anim.flip_h else 1.0
			
		# Thời gian lướt là 0.2s
		get_tree().create_timer(0.2).timeout.connect(_on_dash_finished)
		# Thời gian hồi chiêu lướt là 0.6s
		get_tree().create_timer(0.6).timeout.connect(func(): can_dash = true)

func _apply_dash_movement() -> void:
	player.velocity.y = 0 # Vô hiệu hóa trọng lực khi lướt
	player.velocity.x = player.dash_direction * DASH_SPEED

func _on_dash_finished() -> void:
	if not player.is_dead:
		player.is_dashing = false
		player.combat.is_invincible = false

func _apply_gravity(delta: float) -> void:
	if not player.is_on_floor():
		# Nếu đang rơi, chạm tường và ép phím vào tường -> Trượt tường
		if player.velocity.y > 0 and player.is_on_wall() and player.direction != 0 and player.direction == -sign(player.get_wall_normal().x):
			player.velocity.y = min(player.velocity.y + player.get_gravity().y * delta, WALL_SLIDE_SPEED)
			jump_count = 0 # Cho phép nhảy đúp sau khi rời tường
		else:
			player.velocity += player.get_gravity() * delta
	else:
		jump_count = 0


func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		# Wall Jump: Chạm tường, trên không, và đang ép vào tường
		if player.is_on_wall() and not player.is_on_floor() and player.direction != 0 and player.direction == -sign(player.get_wall_normal().x):
			player.velocity.y = JUMP_VELOCITY
			# Bật ra hướng ngược lại với bức tường
			player.velocity.x = sign(player.get_wall_normal().x) * WALL_JUMP_VELOCITY_X
			jump_count = 1
			# Khóa di chuyển ngang trong 0.2s để lực bật không bị ghi đè
			wall_jump_lock = true
			get_tree().create_timer(0.2).timeout.connect(func(): wall_jump_lock = false)
		elif jump_count < MAX_JUMPS:
			player.velocity.y = JUMP_VELOCITY
			jump_count += 1

func _handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and not player.is_attacking:
		player.is_attacking = true
		player.hitbox_collision.disabled = false # Bật vùng sát thương lên
		
		# Ép Godot quét lại các mục tiêu đang đứng đè lên nhau (Sửa lỗi chém trượt khi đứng im)
		var hitbox = player.hitbox_collision.get_parent()
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitoring", true)

func _handle_horizontal() -> void:
	if wall_jump_lock:
		return # Không ghi đè velocity.x nếu vừa bật tường
		
	if player.direction != 0:
		player.velocity.x = player.direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
