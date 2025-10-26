extends PlayerState
class_name FallState

func enter() -> void:
	animation_player.play("idle")  # Когда будет анимация "fall", поменять на строку `animation_player.play("fall")`
	#animation_player.play("fall")

func physics_process(delta: float) -> void:
	var input_dir = get_movement_input()

	# Воздушный контроль при падении (меньше чем в прыжке)
	var air_control_factor = player.player_data.air_control * 0.7
	var target_velocity = input_dir * player.player_data.walk_speed * air_control_factor
	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 3 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("AttackState"))
		return

	if player.is_on_floor():
		audio_component.play_land()
		_transition_to_ground_state()

func _transition_to_ground_state():
	var input_dir = get_movement_input()

	if input_dir.length() > 0:
		if Input.is_action_pressed("sprint"):
			state_machine.change_state(state_machine.get_node("RunState"))
		else:
			state_machine.change_state(state_machine.get_node("WalkState"))
	else:
		state_machine.change_state(state_machine.get_node("IdleState"))

func _apply_gravity(delta: float):
	player.velocity.y -= player.GRAVITY * delta
