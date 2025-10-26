extends PlayerState
class_name JumpState

var has_jumped: bool = false

func enter() -> void:
	animation_player.play("idle")  # Когда будет анимация "jump", поменять на строку `animation_player.play("jump")`
	#animation_player.play("jump")
	audio_component.play_jump()
	has_jumped = false

func physics_process(delta: float) -> void:
	if not has_jumped:
		player.velocity.y = player.player_data.jump_velocity
		has_jumped = true

	var input_dir = get_movement_input()

	# Воздушный контроль
	var target_velocity = input_dir * player.player_data.walk_speed * player.player_data.air_control
	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 5 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("AttackState"))
		return

	# Переход в падение
	if player.velocity.y <= 0:
		state_machine.change_state(state_machine.get_node("FallState"))

func _apply_gravity(delta: float):
	player.velocity.y -= player.GRAVITY * delta
