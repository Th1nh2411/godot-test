extends Area2D

@export var next_scene_path: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Bật animation xoay vòng/lung linh của cánh cổng ngay khi game vừa chạy
	var anim_sprite = get_node_or_null("AnimatedSprite2D")
	if anim_sprite:
		anim_sprite.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body is Player: # Phải kiểm tra là Player trước, tránh quái vật đi nhầm vào cổng
		if next_scene_path != "":
			print("Victory! Chuyển sang màn: ", next_scene_path)
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("Victory! (Nhưng chưa cài đường dẫn màn chơi tiếp theo)")
