extends PlayerState
class_name RunState

func enter() -> void:
	animation_player.play("idle")  # Когда будет анимация "run", поменять на строку `animation_player.play("run")`
	#animation_player.play("run")
	audio_component.start_moving()

func exit() -> void:
	audio_component.stop_moving()

func physics_process(delta: float) -> void:
	var input_dir = get_movement_input()

	if input_dir.length() == 0:
		state_machine.change_state(state_machine.get_node("IdleState"))
		return

	if not Input.is_action_pressed("sprint") or not _has_stamina():
		state_machine.change_state(state_machine.get_node("WalkState"))
		return

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state(state_machine.get_node("JumpState"))
		return

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("AttackState"))
		return

	# Движение относительно камеры
	var camera_relative_dir = player.get_camera_relative_direction(input_dir)
	var target_velocity = camera_relative_dir * player.player_data.run_speed

	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 15 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

# TODO: Будущая механика стамины
func _has_stamina() -> bool:
	return true
