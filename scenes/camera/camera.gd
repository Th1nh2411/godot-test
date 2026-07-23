extends Node2D

@export var player: CharacterBody2D

var shake_strength: float = 0.0
var shake_fade: float = 10.0 # Tốc độ giảm dần độ rung
var rng = RandomNumberGenerator.new()

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	# Đăng ký Camera vào hệ thống để bất kỳ ai cũng có thể gọi rung màn hình
	add_to_group("camera")
	rng.randomize()

func apply_shake(strength: float) -> void:
	shake_strength = strength

func _process(delta: float) -> void:
	if shake_strength > 0:
		# Giảm dần độ rung theo thời gian (lerpf trong Godot 4)
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		
		# Tính toán dịch chuyển ngẫu nhiên
		var offset_x = rng.randf_range(-shake_strength, shake_strength)
		var offset_y = rng.randf_range(-shake_strength, shake_strength)
		camera.offset = Vector2(offset_x, offset_y)
		
		# Cắt đuôi để về 0 nhanh hơn khi độ rung quá nhỏ
		if shake_strength < 1.0:
			shake_strength = 0.0
	else:
		# Trả camera về tĩnh lặng
		camera.offset = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if player:
		global_position.x = player.global_position.x
