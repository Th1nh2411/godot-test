extends Area2D

# Đảm bảo mỗi Checkpoint chỉ được kích hoạt 1 lần
var is_activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Mặc định phát animation 'no_flag' (nếu có)
	var anim = get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("no_flag")

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
		
	if body is Player:
		is_activated = true
		# Lưu vị trí hiện tại của Checkpoint vào Biến Toàn Cục
		GameManager.last_checkpoint_pos = global_position
		print("Đã lưu Checkpoint tại: ", global_position)
		
		# Chạy hiệu ứng cắm cờ
		var anim = get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play("flag_out")
			# Chờ hiệu ứng cắm cờ (flag_out) chạy xong
			await anim.animation_finished
			# Chuyển sang hiệu ứng lá cờ bay bay (flag_idle)
			anim.play("flag_idle")
			
		# (Tùy chọn) Phát âm thanh ăn checkpoint
		var sound = get_node_or_null("AudioStreamPlayer")
		if sound:
			sound.play()
