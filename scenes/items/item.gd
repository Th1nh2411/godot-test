extends Area2D
class_name ItemComponent

# Định nghĩa các loại vật phẩm
enum ItemType { COIN, FRUIT }

@export var type: ItemType = ItemType.COIN
@export var value: int = 10

func _ready() -> void:
	# Tự động kết nối sự kiện khi có vật thể chạm vào
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Kiểm tra xem người vừa chạm vào có phải là Player không
	if body is Player:
		if type == ItemType.COIN:
			# Gọi hàm nhặt tiền (tí nữa sẽ viết trong player.gd)
			if body.has_method("add_score"):
				body.add_score(value)
		elif type == ItemType.FRUIT:
			# Gọi hàm hồi máu
			if body.combat:
				body.combat.heal(value)
		
		# (Tùy chọn) Chơi một âm thanh nhặt đồ hoặc hiệu ứng hạt ở đây
		
		# Nhặt xong thì xóa vật phẩm khỏi thế giới
		queue_free()
