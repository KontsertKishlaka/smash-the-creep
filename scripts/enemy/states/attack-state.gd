extends EnemyState
class_name AttackState

@export var state_enum: int = EnemyStatesEnum.State.AttackState

# --- Внутренние ---
var attacking_air: bool = false
var attack_cooldown_timer: float = 0.0
var attack_area: Area3D = null
var target: Node3D = null
var is_bouncing: bool = false
var bounce_initialized: bool = false
var post_attack_delay_timer: float = 0.0

func enter():
	attack_area = slime.get_node("AttackArea")
	attack_area.monitoring = true

	if not attack_area.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
		attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
	if not attack_area.is_connected("body_exited", Callable(self, "_on_attack_area_body_exited")):
		attack_area.connect("body_exited", Callable(self, "_on_attack_area_body_exited"))

	# если цель уже известна — используем её, иначе пытаемся взять игрока
	if slime.player and is_instance_valid(slime.player):
		target = slime.player
	else:
		target = null

	attacking_air = true
	is_bouncing = false
	bounce_initialized = false
	post_attack_delay_timer = 0.0
	attack_cooldown_timer = 0.0

	print(slime.name, " - вошёл в AttackState, target = ", target)

	# Первый прыжок к цели
	_request_attack_jump()


func physics_update(delta):
	if not slime.data or not is_instance_valid(slime):
		return

	# --- Фаза отскока ---
	if is_bouncing:
		_update_bounce(delta)
		return

	# --- Если цели нет — возвращаемся в Chase ---
	if target == null or not is_instance_valid(target):
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		return

	var to_target = target.global_position - slime.global_position
	var distance = to_target.length()
	var dir = to_target.normalized()

	# --- Полёт к цели ---
	if attacking_air:
		# горизонтальная тяга к цели
		slime.velocity.x = dir.x * slime.data.speed * 0.75
		slime.velocity.z = dir.z * slime.data.speed * 0.75

		# гравитация
		slime.velocity.y -= slime.data.gravity * delta

		# условие атаки
		if distance <= slime.data.attack_range or slime.is_on_floor():
			_perform_attack()
			post_attack_delay_timer = 0.06  # небольшая пауза перед отскоком
			attacking_air = false
			attack_area.monitoring = false
	else:
		# --- Пауза перед отскоком ---
		if post_attack_delay_timer > 0.0:
			post_attack_delay_timer -= delta
			slime.velocity.y -= slime.data.gravity * delta
			if post_attack_delay_timer <= 0.0:
				_start_bounce()
			return

		# --- Обычное торможение ---
		slime.velocity.x = move_toward(slime.velocity.x, 0.0, delta * 4.0)
		slime.velocity.z = move_toward(slime.velocity.z, 0.0, delta * 4.0)
		slime.velocity.y -= slime.data.gravity * delta

		if slime.is_on_floor() and distance > slime.data.attack_range:
			state_machine.change_state(EnemyStatesEnum.State.ChaseState)

	# кулдаун
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta


# === SIGNALS ===
func _on_attack_area_body_entered(body):
	if body is Player and body.has_method("take_damage"):
		if target == null:
			target = body
		if body == slime.player:
			target = body

func _on_attack_area_body_exited(body):
	if body == target:
		target = null


# === HELPERS ===
func _request_attack_jump():
	if slime.player and is_instance_valid(slime.player):
		var to_player = slime.player.global_position - slime.global_position
		var dir = to_player.normalized()
		slime.velocity.x = dir.x * slime.data.speed * 0.7
		slime.velocity.z = dir.z * slime.data.speed * 0.7
		slime.velocity.y = slime.data.attack_jump_velocity * 0.95
	attacking_air = true


func _perform_attack():
	if attack_cooldown_timer > 0.0 or not is_instance_valid(target):
		return
	if target.has_method("take_damage"):
		target.take_damage(slime.data.attack_damage, slime)
		print(slime.name, " нанёс ", slime.data.attack_damage, " урона ", target.name)
	else:
		print("Цель не имеет метода take_damage — атака пропущена")
	attack_cooldown_timer = slime.data.attack_cooldown


func _start_bounce():
	if target == null and slime.player and is_instance_valid(slime.player):
		target = slime.player
	if not is_instance_valid(target):
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		return

	var away = (slime.global_position - target.global_position).normalized()

	# сброс горизонтальной скорости
	slime.velocity.x = 0
	slime.velocity.z = 0

	var base_h = slime.data.attack_jump_velocity * slime.data.attack_knockback_horizontal
	var base_v = slime.data.attack_jump_velocity * slime.data.attack_knockback_vertical
	var power = 1.0
	var variation = 0.0

	if "attack_bounce_power" in slime.data:
		power = slime.data.attack_bounce_power
	if "attack_bounce_variation" in slime.data:
		variation = slime.data.attack_bounce_variation

	var rnd = 1.0 + randf_range(-variation, variation)
	var horiz = clamp(base_h * power * rnd, -slime.data.speed * 6.0, slime.data.speed * 6.0)
	var vert  = base_v * power * rnd

	slime.velocity.x = away.x * horiz
	slime.velocity.z = away.z * horiz
	slime.velocity.y = vert

	# --- Звук атаки / приземления с рандомной тональностью ---
	if is_instance_valid(slime) and slime.land_sound:
		slime.land_sound.pitch_scale = randf_range(0.9, 1.2)  # рандом от 0.9 до 1.2
		slime._play_land_sound()

	is_bouncing = true
	bounce_initialized = true
	attacking_air = false
	attack_area.monitoring = false


func _update_bounce(delta):
	slime.velocity.y -= slime.data.gravity * delta

	if slime.is_on_floor():
		is_bouncing = false
		bounce_initialized = false
		attack_area.monitoring = true
		# если игрок далеко — возвращаемся в Chase
		if target and is_instance_valid(target):
			var to_target = target.global_position - slime.global_position
			if to_target.length() > slime.data.attack_range * 1.2:
				state_machine.change_state(EnemyStatesEnum.State.ChaseState)
