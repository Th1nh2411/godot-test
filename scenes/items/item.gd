extends Area2D
class_name ItemComponent

# Định nghĩa các loại vật phẩm
enum ItemType { COIN, FRUIT }

@export var type: ItemType = ItemType.COIN
@export var value: int = 10

# Các biến dùng cho hiệu ứng lơ lửng (Animation lơ lửng)
@export var float_speed: float = 4.0
@export var float_distance: float = 4.0
var original_y: float = 0.0
var time_passed: float = 0.0
var is_collected: bool = false # Tránh việc 1 đồng xu bị nhặt 2 lần

func _ready() -> void:
	# Lưu vị trí Y ban đầu để tính toán sóng Sin
	original_y = global_position.y
	
	# Random thời gian để các đồng xu không bay lên xuống đều tăm tắp
	time_passed = randf() * PI * 2.0
	
	# Nếu bạn dùng AnimatedSprite2D cho Item, tự động bắt nó chạy animation 'default'
	var anim_sprite = get_node_or_null("AnimatedSprite2D")
	if anim_sprite:
		anim_sprite.play("default")
		
	# Tự động kết nối sự kiện khi có vật thể chạm vào
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Tạo hiệu ứng lơ lửng (bobbing) cực kỳ mượt mà
	time_passed += delta
	global_position.y = original_y + sin(time_passed * float_speed) * float_distance

func _on_body_entered(body: Node2D) -> void:
	# Nếu đồ đã bị nhặt rồi thì bỏ qua
	if is_collected:
		return
		
	# Kiểm tra xem người vừa chạm vào có phải là Player không
	if body is Player:
		is_collected = true # Đánh dấu đã nhặt
		
		if type == ItemType.COIN:
			# Gọi hàm nhặt tiền (tí nữa sẽ viết trong player.gd)
			if body.has_method("add_score"):
				body.add_score(value)
		elif type == ItemType.FRUIT:
			# Gọi hàm hồi máu
			if body.combat:
				body.combat.heal(value)
		
		# Tìm AnimatedSprite2D để chạy hiệu ứng nổ/thu thập
		var anim_sprite = get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.play("collected")
			
			# Tắt va chạm để item không chặn đường hoặc kích hoạt nhầm lần nữa
			var col = get_node_or_null("CollisionShape2D")
			if col:
				col.set_deferred("disabled", true)
			
			# Dừng hiệu ứng lơ lửng lại
			set_process(false)
			
			# Chờ animation chạy xong rồi mới xóa
			await anim_sprite.animation_finished
			queue_free()
		else:
			# Nếu không có Sprite thì xóa luôn như cũ
			queue_free()
