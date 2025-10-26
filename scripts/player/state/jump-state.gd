extends PlayerState

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
		print("Jump started, velocity.y: ", state_machine.player.velocity.y)

func physics_update(delta):
	if not state_machine or not state_machine.player:
		return
	# Вызываем _handle_movement с air params
	state_machine._handle_movement(delta, true, air_drag, air_acceleration, max_air_speed)
	if Input.is_action_pressed("attack"):
		state_machine.change_state("attack")
	# Transition на пол уже в _handle_movement, но для clarity
	if state_machine.player.is_on_floor():
		state_machine.change_state("idle")  # Или walk/run на основе input (уже в _handle)
