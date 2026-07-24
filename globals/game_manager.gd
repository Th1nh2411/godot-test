extends Node

# Vị trí cuối cùng mà người chơi lưu game. Bằng (0,0) nghĩa là chưa lưu.
var last_checkpoint_pos: Vector2 = Vector2.ZERO

# Hàm gọi khi người chơi đi qua cửa để sang level khác (Reset lại vị trí lưu)
func reset_checkpoint() -> void:
	last_checkpoint_pos = Vector2.ZERO
