extends CharacterBody2D

# Thêm trạng thái DIE và HIT
enum State { PATROL, CHASE, ATTACK, DIE, HIT }
var current_state := State.PATROL
var player_target: Player = null

var direction := 1
var speed := 100.0
var chase_speed := 150.0
var attack_range := 40.0 # Khoảng cách kích hoạt đấm

@onready var wall_detector: RayCast2D = $WallDetector
@onready var floor_detector: RayCast2D = $FloorDetector
@onready var combat = $Combat
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	combat.died.connect(_on_died)
	combat.hp_changed.connect(_on_hp_changed)
	combat.knockback_received.connect(_on_knockback_received)
	anim.animation_finished.connect(_on_animation_finished)
	# Cập nhật hướng ngay khi quái vật vừa sinh ra
	_flip(direction)

func _on_knockback_received(force: Vector2) -> void:
	# Bị đẩy lùi
	velocity = force

func _physics_process(delta: float) -> void:
	# Bật Hitbox (gây sát thương) CHỈ KHI đang ở trạng thái đấm
	hitbox_collision.disabled = (current_state != State.ATTACK)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match current_state:
		State.PATROL:
			_process_patrol()
		State.CHASE:
			_process_chase()
		State.ATTACK:
			velocity.x = 0
		State.DIE:
			# Cho phép văng lùi khi chết thay vì khựng lại
			velocity.x = move_toward(velocity.x, 0, 800 * delta)
		State.HIT:
			# Cho phép văng lùi và trượt chậm dần (Ma sát = 800)
			velocity.x = move_toward(velocity.x, 0, 800 * delta)
			
	move_and_slide()
	_update_animation_continuous()

# Hàm mới: Chỉ gọi 1 lần khi chuyển trạng thái
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	
	# Gọi Animation 1 lần duy nhất khi mới bước vào trạng thái
	match current_state:
		State.ATTACK:
			anim.stop()
			anim.play("attack")
			var ap = get_node_or_null("AnimationPlayer")
			if ap:
				ap.stop()
				ap.seek(0.0, true) # Ép buộc trả hoạt ảnh về giây số 0
				ap.play("attack_hitbox")
		State.DIE:
			anim.play("die")
		State.HIT:
			anim.play("hit")

func _flip(dir: int) -> void:
	if dir == 0:
		return
	
	# Do ảnh gốc vẽ quay mặt sang TRÁI, nên khi đi sang PHẢI (dir > 0) ta mới cần lật ảnh (flip_h = true)
	anim.flip_h = (dir > 0)
	
	# 2. Lật Hitbox để AnimationPlayer đánh đúng hướng
	var hitbox = get_node_or_null("Hitbox")
	if hitbox:
		hitbox.scale.x = dir
		
	# 3. Lật các tia dò đường (RayCast)
	wall_detector.scale.x = dir
	floor_detector.scale.x = dir

func _process_patrol() -> void:
	# Chỉ kiểm tra quay đầu khi đã thực sự chạm đất (Tránh lỗi Raycast chưa kịp load ở Frame 0)
	if is_on_floor():
		if wall_detector.is_colliding() or not floor_detector.is_colliding():
			direction *= -1
			_flip(direction)
		
	velocity.x = direction * speed

func _process_chase() -> void:
	if player_target:
		var dir_to_player = sign(player_target.global_position.x - global_position.x)
		if dir_to_player != 0:
			direction = dir_to_player
			_flip(direction)
			
		if global_position.distance_to(player_target.global_position) <= attack_range:
			change_state(State.ATTACK)
			return
			
		if not floor_detector.is_colliding() or wall_detector.is_colliding():
			velocity.x = 0
		else:
			velocity.x = direction * chase_speed

# Chỉ xử lý các animation chạy liên tục (như đi bộ, đứng im)
func _update_animation_continuous() -> void:
	if current_state == State.PATROL or current_state == State.CHASE:
		if velocity.x != 0:
			anim.play("run")
		else:
			anim.play("idle")

func _on_animation_finished() -> void:
	if current_state == State.DIE:
		queue_free()
		return
			
	if anim.animation == "attack":
		if player_target:
			change_state(State.CHASE)
		else:
			change_state(State.PATROL)

func _on_hp_changed(current_hp: int, max_hp: int) -> void:
	if current_state != State.DIE:
		change_state(State.HIT)
		get_tree().create_timer(0.5).timeout.connect(_on_stun_finished)

func _on_stun_finished() -> void:
	if current_state == State.HIT:
		if player_target:
			change_state(State.CHASE)
		else:
			change_state(State.PATROL)

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player and current_state != State.DIE: 
		player_target = body
		change_state(State.CHASE)

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is Player and current_state != State.DIE:
		player_target = null
		if current_state != State.ATTACK:
			change_state(State.PATROL)

func _on_died() -> void:
	change_state(State.DIE)
	var hurtbox_col = get_node_or_null("Hurtbox/CollisionShape2D")
	if hurtbox_col:
		hurtbox_col.set_deferred("disabled", true)
