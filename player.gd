extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002
@export var max_degree: float = 45

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		var camera = get_node("Camera3D")

		if camera:
			var current_rotation_x = camera.rotation_degrees.x
			var target_rotation_x = clamp(current_rotation_x - event.relative.y * mouse_sensitivity * 100, -max_degree, max_degree)
			camera.rotation_degrees.x = target_rotation_x

const SPEED = 2
const JUMP_VELOCITY = 50
const GRAVITY = 9.8

var y_velocity = 0

func _physics_process(delta: float):
	
	print("Is on floor: ", is_on_floor())
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		y_velocity = JUMP_VELOCITY
	
	if not is_on_floor():
		y_velocity -= GRAVITY * delta
	else:
		y_velocity = 0

	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("move_forwards"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backwards"):
		input_dir.z += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1


	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

   
	var direction = (transform.basis * input_dir).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	velocity.y = y_velocity  

	move_and_slide()
