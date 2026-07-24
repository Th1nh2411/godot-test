extends AnimatableBody2D

# Khoảng cách di chuyển (Mặc định đi ngang 200 pixel)
@export var move_distance: Vector2 = Vector2(200, 0)
# Tốc độ di chuyển
@export var speed: float = 1.0

var start_pos: Vector2
var time_passed: float = 0.0

func _ready() -> void:
	# Ghi nhớ vị trí xuất phát khi game bắt đầu
	start_pos = global_position
	var anim_sprite = get_node_or_null("AnimatedSprite2D")
	if anim_sprite:
		anim_sprite.play("default")

func _physics_process(delta: float) -> void:
	time_passed += delta * speed
	
	# Sóng sin dao động từ -1 đến 1. 
	# Biến đổi nó thành từ 0 đến 1 để dễ bề tính toán quãng đường
	var t = (sin(time_passed) + 1.0) / 2.0
	
	# Cập nhật vị trí. AnimatableBody2D sẽ tự động hiểu và chở Player đi theo!
	global_position = start_pos.lerp(start_pos + move_distance, t)
