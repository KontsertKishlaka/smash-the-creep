extends "res://scripts/player/state.gd"

@export var jump_speed = 7
@export var air_drag: float = 0.98
@export var air_acceleration: float = 10

var max_air_speed: float = 0.0

func enter():
	if state_machine and state_machine.player:
		var velocity = state_machine.player.velocity
		if Vector2(velocity.x, velocity.z).length() == 0:
			max_air_speed = 3
		else:
			max_air_speed = Vector2(velocity.x, velocity.z).length()
		velocity.y = jump_speed
		state_machine.player.velocity = velocity
		state_machine.player.move_and_slide()
		#Отладка прыжка
		print("Jump started, velocity.y: ", state_machine.player.velocity.y)

func physics_update(delta):
	#Отладка связей узлов
	if not state_machine or not state_machine.player:
		return
	
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("move_forwards"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backwards"):
		input_dir.z += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	
	var velocity = state_machine.player.velocity
	
	var desired_velocity = Vector3.ZERO
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		var direction = (state_machine.player.transform.basis * input_dir).normalized()
		desired_velocity = direction * max_air_speed
	
	velocity.x = move_toward(velocity.x, desired_velocity.x, air_acceleration * delta)
	velocity.z = move_toward(velocity.z, desired_velocity.z, air_acceleration * delta)
	
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	horizontal_velocity *= air_drag
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.y

#Гравитация

	velocity.y -= state_machine.player.GRAVITY * delta

	state_machine.player.velocity = velocity

	state_machine.player.move_and_slide()
	
	if state_machine.player.is_on_floor():
		if input_dir.length() > 0:
			if Input.is_action_pressed("sprint"):
				state_machine.change_state("run")
			else:
				state_machine.change_state("walk")
		else:
			state_machine.change_state("idle")
