extends PlayerState
class_name AttackState

@onready var hitbox: Area3D = $"../../Camera/PivotArm/Mesh/Hitbox"

var current_attack: int = 1
var attack_completed: bool = false
var can_combo: bool = false
var combo_queued: bool = false

# Вынесем замедление атаки в конфиг
var attack_slowdown: float = 0.85

func enter() -> void:
	current_attack = 1
	attack_completed = false
	can_combo = false
	combo_queued = false

	# Берем замедление из player_data если есть, иначе используем дефолтное
	if player.player_data and player.player_data.has_method("get_attack_slowdown"):
		attack_slowdown = player.player_data.get_attack_slowdown()
	else:
		attack_slowdown = 0.85

	_play_attack_animation()
	audio_component.play_attack()

	# Включаем Area3D в середине анимации
	await get_tree().create_timer(0.2).timeout
	if hitbox:
		hitbox.monitoring = true
		if not hitbox.area_entered.is_connected(_on_attack_hit):
			hitbox.area_entered.connect(_on_attack_hit)

	# Разрешаем комбо во второй половине анимации
	await get_tree().create_timer(0.3).timeout
	can_combo = true

func exit() -> void:
	if hitbox:
		hitbox.monitoring = false
		if hitbox.area_entered.is_connected(_on_attack_hit):
			hitbox.area_entered.disconnect(_on_attack_hit)

func _play_attack_animation():
	var anim_name = "attack_" + str(current_attack)
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

		# Ждем завершения анимации
		await animation_player.animation_finished

		# После завершения анимации проверяем комбо
		if combo_queued and current_attack < 2:
			# Переходим к следующей атаке в комбо
			current_attack += 1
			combo_queued = false
			can_combo = false
			_play_attack_animation()

			# Снова включаем Area3D для второй атаки
			await get_tree().create_timer(0.2).timeout
			if hitbox:
				hitbox.monitoring = true
		else:
			# Комбо не запрошено - завершаем атаку
			attack_completed = true
	else:
		# Если анимации нет, сразу завершаем
		attack_completed = true

func physics_process(delta: float) -> void:
	# Ограниченное движение во время атаки
	var input_dir = get_movement_input()
	var camera_relative_dir = player.get_camera_relative_direction(input_dir)
	var move_speed = player.player_data.walk_speed * attack_slowdown

	var target_velocity = camera_relative_dir * move_speed
	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 8 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

	# Проверяем ввод для комбо (используем is_action_pressed для зажатия)
	if can_combo and Input.is_action_pressed("attack"):
		combo_queued = true

	# Переход после завершения атаки
	if attack_completed:
		_transition_from_attack()

func _on_attack_hit(area: Area3D):
	var hit_layer = area.collision_layer
	var target = area.get_parent()

	# ДЕБАГ: Выведем информацию о столкновении
	print("Атака попала в объект: ", target.name)
	print("Слой объекта: ", hit_layer)
	print("Ожидаемые слои: ENEMY=", Constants.LAYERS.ENEMY, ", DESTRUCTIBLE=", Constants.LAYERS.DESTRUCTIBLE)

	# Проверяем битовую маску правильно
	var is_enemy = (hit_layer & Constants.LAYERS.ENEMY) != 0
	var is_destructible = (hit_layer & Constants.LAYERS.DESTRUCTIBLE) != 0

	if is_enemy or is_destructible:
		print("\n✅ Попадание по цели: ", target.name)

		# Отправляем сигнал атаки
		SignalBus.emit_signal("player_attacked", target, player.player_data.base_attack_damage)

		# Дополнительно: если у цели есть метод take_hit или _take_hit
		if target and target.has_method("take_hit"):
			target.take_hit(player.player_data.base_attack_damage)
		elif target and target.has_method("_take_hit"):
			target._take_hit(player.player_data.base_attack_damage)
	else:
		print("\n❌ Объект не является врагом или разрушаемым объектом")

func _transition_from_attack():
	if not player.is_on_floor():
		state_machine.change_state(state_machine.get_node("FallState"))
	else:
		var input_dir = get_movement_input()
		if input_dir.length() > 0:
			if Input.is_action_pressed("sprint"):
				state_machine.change_state(state_machine.get_node("RunState"))
			else:
				state_machine.change_state(state_machine.get_node("WalkState"))
		else:
			state_machine.change_state(state_machine.get_node("IdleState"))
