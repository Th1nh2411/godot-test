extends CharacterBody2D

# Định nghĩa 2 trạng thái: Đi tuần ngớ ngẩn (PATROL) và Rượt đuổi (CHASE)
enum State { PATROL, CHASE }
var current_state := State.PATROL
var player_target: Player = null

var direction := 1
var speed := 100.0
var chase_speed := 150.0 # Khi rượt đuổi thì chạy nhanh hơn

@onready var wall_detector: RayCast2D = $WallDetector
@onready var floor_detector: RayCast2D = $FloorDetector
@onready var combat = $Combat

func _ready() -> void:
	# Kết nối tín hiệu: Khi Combat báo là máu = 0, thì gọi hàm quái vật chết
	combat.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# BỘ NÃO CHUYỂN TRẠNG THÁI
	match current_state:
		State.PATROL:
			_process_patrol()
		State.CHASE:
			_process_chase()
			
	move_and_slide()

# AI 1: Hàm đi tuần tra
func _process_patrol() -> void:
	if wall_detector.is_colliding() or not floor_detector.is_colliding():
		direction *= -1
		scale.x = direction # Lật mặt theo hướng đi
		
	velocity.x = direction * speed

# AI 2: Hàm rượt đuổi
func _process_chase() -> void:
	if player_target:
		# Tính toán hướng của người chơi so với quái (sign trả về -1 nếu bên trái, 1 nếu bên phải)
		var dir_to_player = sign(player_target.global_position.x - global_position.x)
		
		# BẢO VỆ MẠNG SỐNG: Nếu đang chạy rượt theo mà tới bờ vực hoặc đụng tường thì thắng gấp!
		if not floor_detector.is_colliding() or wall_detector.is_colliding():
			velocity.x = 0
		else:
			direction = dir_to_player
			velocity.x = direction * chase_speed
			
			if direction != 0:
				scale.x = direction # Lật mặt quay về hướng Player

# CẢM BIẾN 1: Phát hiện có người bước vào vùng tròn
func _on_player_detector_body_entered(body: Node2D) -> void:
	# Nếu cái vừa bước vào là Player (chứ không phải cục đá hay quái khác)
	if body is Player: 
		player_target = body
		current_state = State.CHASE

# CẢM BIẾN 2: Người chơi chạy thoát khỏi vùng tròn
func _on_player_detector_body_exited(body: Node2D) -> void:
	if body is Player:
		player_target = null
		current_state = State.PATROL
		direction = int(scale.x) # Tiếp tục đi tuần theo hướng đang nhìn dở

func _on_died() -> void:
	queue_free()
