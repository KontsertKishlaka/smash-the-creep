extends EnemyState

func physics_update(delta):
	if not slime.player:
		return

	slime.jump_timer -= delta

	var to_player = slime.player.global_position - slime.global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	# --- Движение к игроку ---
	slime.velocity.x = dir.x * slime.speed
	slime.velocity.z = dir.z * slime.speed
	slime._rotate_toward(dir, delta)

	# --- Прыжок на игрока, если близко ---
	if slime.is_on_floor() and slime.jump_timer <= 0.0 and distance < slime.jump_distance:
		slime.velocity.y = slime.jump_velocity
		slime.jump_timer = slime.jump_cooldown

	# --- Если игрок ушёл далеко, возвращаемся к патрулю ---
	if distance > slime.detection_range * 1.5:
		state_machine.change_state("PatrolState")
