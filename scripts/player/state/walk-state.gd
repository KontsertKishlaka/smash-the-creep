extends PlayerState
class_name WalkState

func enter() -> void:
	animation_player.play("idle")  # Когда будет анимация "walk", поменять на строку `animation_player.play("walk")`
	#animation_player.play("walk")
	audio_component.start_moving()

func exit() -> void:
	audio_component.stop_moving()

func physics_process(delta: float) -> void:
	var input_dir = get_movement_input()

	if input_dir.length() == 0:
		state_machine.change_state(state_machine.get_node("IdleState"))
		return

	if Input.is_action_pressed("sprint") and _has_stamina():
		state_machine.change_state(state_machine.get_node("RunState"))
		return

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state(state_machine.get_node("JumpState"))
		return

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("AttackState"))
		return

	# Плавное движение
	var target_velocity = input_dir * player.player_data.walk_speed
	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 10 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

func _has_stamina() -> bool:
	# В будущем можно добавить систему стамины
	return true

func _apply_gravity(delta: float):
	player.velocity.y -= player.GRAVITY * delta
