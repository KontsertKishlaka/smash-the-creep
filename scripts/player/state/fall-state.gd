extends PlayerState
class_name FallState

func enter() -> void:
	animation_player.play("idle")  # Когда будет анимация "fall", поменять на строку `animation_player.play("fall")`
	#animation_player.play("fall")

func physics_process(delta: float) -> void:
	var input_dir = get_movement_input()
	var camera_relative_dir = player.get_camera_relative_direction(input_dir)

	# Воздушный контроль при падении
	var air_control_factor = player.player_data.air_control * 0.7
	var target_velocity = camera_relative_dir * player.player_data.walk_speed * air_control_factor
	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 3 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

	# Проверка атаки в воздухе
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("AttackState"))
		return

	if player.is_on_floor():
		audio_component.play_land()
		_transition_to_ground_state()

func post_physics_process(_delta: float) -> void:
	if player.has_node(Constants.PUSH_COMPONENT):
		player.get_node(Constants.PUSH_COMPONENT).push_rigid_bodies()

func _transition_to_ground_state():
	var input_dir = get_movement_input()

	if input_dir.length() > 0:
		if Input.is_action_pressed("sprint"):
			state_machine.change_state(state_machine.get_node("RunState"))
		else:
			state_machine.change_state(state_machine.get_node("WalkState"))
	else:
		state_machine.change_state(state_machine.get_node("IdleState"))
