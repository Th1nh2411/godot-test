extends Area2D
class_name HitboxComponent

@export var damage: int = 10
@export var knockback_power: Vector2 = Vector2(300, -150) # X: đẩy lùi, Y: hất tung lên

func _ready() -> void:
	# Kết nối tự động: Khi có một Area2D khác chạm vào vùng này
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# Nếu cái mà ta vừa chạm vào là một Hurtbox
	if area is HurtboxComponent:
		# LƯU Ý QUAN TRỌNG: Ngăn chặn việc tự chém chính mình!
		if area.owner == self.owner:
			return
			
		# Tính toán hướng đẩy (Người chém đang đứng bên trái hay bên phải mục tiêu)
		var dir = sign(area.global_position.x - global_position.x)
		if dir == 0: dir = 1
		
		# Áp dụng lực đẩy theo đúng hướng
		var applied_knockback = Vector2(knockback_power.x * dir, knockback_power.y)
		
		# Truyền lực đẩy vào cùng với sát thương
		area.take_damage(damage, applied_knockback)
