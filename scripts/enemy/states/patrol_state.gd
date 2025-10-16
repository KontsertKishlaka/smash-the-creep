extends EnemyState

func enter():
	# Инициализация при входе в патруль
	slime._set_new_patrol_target()

func physics_update(delta):
	slime.jump_timer -= delta

	# --- Движение к цели ---
	var to_target = slime.patrol_target - slime.global_position
	if to_target.length() < 0.5:
		slime._set_new_patrol_target()

	var dir = to_target.normalized()
	slime.velocity.x = dir.x * slime.speed * 0.5
	slime.velocity.z = dir.z * slime.speed * 0.5
	slime._rotate_toward(dir, delta)

	# --- Случайный прыжок ---
	if slime.is_on_floor() and slime.jump_timer <= 0.0 and randf() < slime.patrol_jump_chance:
		slime.velocity.y = slime.jump_velocity * randf_range(0.6, 1.5)
		slime.jump_timer = slime.jump_cooldown

	# --- Проверка на игрока ---
	if slime.player:
		var distance = (slime.player.global_position - slime.global_position).length()
		if distance < slime.detection_range:
			state_machine.change_state("ChaseState")
