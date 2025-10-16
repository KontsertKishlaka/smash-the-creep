extends EnemyState

func physics_update(delta):
	if not slime.player or not slime.data:
		return

	slime.jump_timer -= delta

	var to_player = slime.player.global_position - slime.global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	# --- Движение к игроку ---
	slime.velocity.x = dir.x * slime.data.speed
	slime.velocity.z = dir.z * slime.data.speed
	slime._rotate_toward(dir, delta)

	# --- Прыжок на игрока, если близко ---
	if slime.is_on_floor() and slime.jump_timer <= 0.0 and distance < slime.data.jump_distance:
		slime.velocity.y = slime.data.jump_velocity
		slime.jump_timer = slime.data.jump_cooldown

	# --- Если игрок ушёл далеко, возвращаемся к патрулю ---
	if distance > slime.data.detection_range * 1.5:
		state_machine.change_state("PatrolState")
