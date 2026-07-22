extends Area2D
class_name HitboxComponent

@export var damage: int = 10

func _ready() -> void:
	# Kết nối tự động: Khi có một Area2D khác chạm vào vùng này
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# Nếu cái mà ta vừa chạm vào là một Hurtbox, ta sẽ gọi hàm nhận sát thương của nó
	if area is HurtboxComponent:
		area.take_damage(damage)
