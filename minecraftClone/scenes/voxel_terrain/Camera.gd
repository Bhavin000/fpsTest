extends Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	get_parent().get_node("Control/Label").text = str(Engine.get_frames_per_second())
	translation -= global_transform.basis.z * delta * 3

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.3
		rotation_degrees.x -= event.relative.y * 0.3
