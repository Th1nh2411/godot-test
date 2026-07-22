extends CanvasLayer

@onready var restart_button: Button = $ColorRect/RestartButton

func _ready() -> void:
	# Bỏ qua luật Pause của game, đảm bảo UI này vẫn bấm được nút
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Dừng hoàn toàn mọi hoạt động của game (Vật lý, Enemy, Player)
	get_tree().paused = true
	
	# Kết nối sự kiện khi bấm nút Restart
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		# Tự động chọn nút này để người chơi có thể bấm phím Enter/Space thay vì click chuột
		restart_button.grab_focus()

func _on_restart_pressed() -> void:
	# Phục hồi lại thời gian của game trước khi load lại màn
	get_tree().paused = false
	# Tải lại màn chơi hiện tại từ đầu
	get_tree().reload_current_scene()
	# Tự hủy màn hình UI này đi
	queue_free()
