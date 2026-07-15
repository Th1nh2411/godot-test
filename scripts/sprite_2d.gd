extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Ready")

@onready var label = $"../Label2"
var rotate_speed = 3.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var speed = 300
	if Input.is_action_pressed("ui_right"):
		position.x += speed * delta

	if Input.is_action_pressed("ui_left"):
		position.x -= speed * delta

	if Input.is_action_pressed("ui_up"):
		position.y -= speed * delta

	if Input.is_action_pressed("ui_down"):
		position.y += speed * delta
	if Input.is_action_pressed("rotate_left"):
		rotation -= rotate_speed * delta
	if Input.is_action_pressed("rotate_right"):
		rotation += rotate_speed * delta
	if Input.is_action_pressed("scale_down"):
		scale -= Vector2.ONE * delta
	if Input.is_action_pressed("scale_up"):
		scale.x += 5 * delta
		scale.y += 5 * delta
	label.text = """
	Position: %s
	Rotation: %.2f
	Scale: %.2f
	FPS: %d
	""" % [
		position,
		rotation,
		scale.x,
		Engine.get_frames_per_second()
	]

func _on_button_pressed() -> void:
	print("Clicked")
