extends KinematicBody

onready var pvt = $pvt
onready var raycast = $pvt/RayCast
onready var cap_height = $CollisionShape

var inner_ = []

var generation_start = -20
var generation_end = 21

var last_pos

onready var objects = [
	$pvt/object/grass,
	$pvt/object/ground,
	$pvt/object/water,
	$pvt/object/stone
]
var key = 0

const GRAVITY = -16.75
const JUMP = 7
const crouch_speed = 40

var direction = Vector2()
const direction_limit = 11

var velocity = Vector3()
export(float) var movement_speed

const default_m_speed = 8.0

export(float) var mouse_sensitivity = 0.1

var can_shoot = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	last_pos = self.global_transform.origin

 ##all input events for weapon##

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var drag = event.relative
		self.rotate_y(deg2rad(drag.x * mouse_sensitivity * -1))
		pvt.rotation.x -= deg2rad(drag.y * mouse_sensitivity)
		pvt.rotation.x = clamp(pvt.rotation.x, deg2rad(-90), deg2rad(90))
	
	if Input.is_key_pressed(KEY_1):
		key = 0
		for i in range(objects.size()):
			if i == key:
				objects[i].visible = true
			else:
				objects[i].visible = false
	elif Input.is_key_pressed(KEY_2):
		key = 1
		for i in range(objects.size()):
			if i == key:
				objects[i].visible = true
			else:
				objects[i].visible = false
	elif Input.is_key_pressed(KEY_3):
		key = 2
		for i in range(objects.size()):
			if i == key:
				objects[i].visible = true
			else:
				objects[i].visible = false
	elif Input.is_key_pressed(KEY_4):
		key = 3
		for i in range(objects.size()):
			if i == key:
				objects[i].visible = true
			else:
				objects[i].visible = false
	
	if Input.is_action_just_pressed("chunk_remove"):
		if raycast.is_colliding():
			get_parent().get_node("Spatial").chunk_deleted(raycast.get_collider())
	
	if Input.is_action_just_pressed("chunk_add"):
		if raycast.is_colliding():
			get_parent().get_node("Spatial").add_chunk(raycast.get_collider(),raycast.get_collision_normal(),key)

func _physics_process(delta):
	_player_movement(delta)
	_chunk_movement()

	##movement##

func _player_movement(delta):
	
	movement_speed = default_m_speed
	
	var DIR = Vector2()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP
	
	if is_on_ceiling():
		velocity.y = -2
	
	if Input.is_action_pressed("forward"):
		direction.y -= 1
	elif Input.is_action_pressed("backward"):
		direction.y += 1
	else:
		direction.y = 0
	
	if Input.is_action_pressed("left"):
		direction.x -= 1
	elif Input.is_action_pressed("right"):
		direction.x += 1
	else:
		direction.x = 0
	
	direction.y = clamp(direction.y, -direction_limit, direction_limit)
	direction.x = clamp(direction.x, -direction_limit, direction_limit)
	DIR = direction.normalized().rotated(-rotation.y)

	velocity.z = DIR.y * movement_speed
	velocity.x = DIR.x * movement_speed
	
	velocity = move_and_slide(velocity, Vector3.UP)

	##weapon pos##

func _chunk_movement():
	var tile_pos = self.global_transform.origin
	tile_pos = Vector3(floor(tile_pos.x), floor(tile_pos.y), floor(tile_pos.z))
	if last_pos == tile_pos:
		return

	get_parent().get_node("Spatial").generate(tile_pos, generation_start, generation_end)

	last_pos = tile_pos
