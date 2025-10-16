extends "res://scripts/player/state.gd"

@export var speed: float = 10

func enter():
	pass

func physics_update(delta):
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("move_forwards"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backwards"):
		input_dir.z += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1

	if input_dir.length() == 0:
		state_machine.change_state("idle")
		return

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

	var direction = (state_machine.player.transform.basis * input_dir).normalized()
	var velocity = state_machine.player.velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	#Гравитация
	
	if not state_machine.player.is_on_floor():
		velocity.y -= state_machine.player.GRAVITY * delta

	state_machine.player.velocity = velocity

	if Input.is_action_just_pressed("jump") and state_machine.player.is_on_floor():
		state_machine.change_state("jump")

	if not Input.is_action_pressed("sprint") and input_dir.length() > 0:
		state_machine.change_state("walk")

	state_machine.player.move_and_slide()
