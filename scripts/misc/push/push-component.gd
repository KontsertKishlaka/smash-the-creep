extends Node
class_name PushComponent

@export_category("Push Configuration")
@export_range(10.0, 200.0, 5.0) var character_mass: float = Constants.DEFAULT_CHARACTER_MASS
@export_range(0.1, 10.0, 0.1) var push_force_multiplier: float = Constants.PUSH_FORCE_MULTIPLIER
@export_range(0.1, 1.0, 0.05) var min_mass_ratio: float = Constants.MIN_MASS_RATIO

@export_category("Sound Configuration")
@export var pusher_type: String = "PLAYER"
@export var enable_push_sounds: bool = true
@export_range(0.1, 10.0, 0.1) var push_sound_threshold: float = Constants.PUSH_SOUND_THRESHOLD

var character_body: CharacterBody3D

func _ready():
	character_body = get_parent() as CharacterBody3D
	if not character_body:
		push_error("❌ 'PushComponent' должен быть дочерним компонентом 'CharacterBody3D'")

# Основной метод толкания - вызывается после move_and_slide()
func push_rigid_bodies() -> void:
	if not character_body:
		return

	var collision_count = character_body.get_slide_collision_count()

	var pushed_count = 0
	for i in collision_count:
		var collision := character_body.get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody3D:
			_handle_rigidbody_collision(collider, collision)
			pushed_count += 1

func _handle_rigidbody_collision(rigidbody: RigidBody3D, collision: KinematicCollision3D) -> void:
	# Вместо использования нормали коллизии, используем направление движения игрока
	var player_horizontal_velocity = Vector3(character_body.velocity.x, 0, character_body.velocity.z)

	# Если игрок не движется, используем направление от игрока к ящику
	if player_horizontal_velocity.length_squared() < 0.1:
		var to_rigidbody = rigidbody.global_position - character_body.global_position
		to_rigidbody.y = 0
		if to_rigidbody.length_squared() > 0.1:
			player_horizontal_velocity = to_rigidbody.normalized() * 1.0  # Минимальная скорость
		else:
			# Если всё равно не можем определить направление, используем нормаль
			player_horizontal_velocity = -collision.get_normal()
			player_horizontal_velocity.y = 0

	var push_dir = player_horizontal_velocity.normalized()

	var velocity_diff = _calculate_velocity_difference(rigidbody, push_dir)

	# Увеличим минимальную разницу скоростей
	if velocity_diff <= 0.1:  # Ранее было 0.0
		velocity_diff = 1.0   # Минимальная сила толчка

	# Остальная логика без изменений...
	var mass_ratio = _calculate_mass_ratio(rigidbody)

	if mass_ratio < min_mass_ratio:
		return

	var final_force = _calculate_final_force(mass_ratio, velocity_diff, push_dir)

	_apply_push_force(rigidbody, final_force, collision.get_position())
	_emit_push_signals(rigidbody, final_force.length())

func _calculate_velocity_difference(rigidbody: RigidBody3D, push_dir: Vector3) -> float:
	var character_vel_in_dir = character_body.velocity.dot(push_dir)
	var rigidbody_vel_in_dir = rigidbody.linear_velocity.dot(push_dir)
	return max(0.0, character_vel_in_dir - rigidbody_vel_in_dir)

func _calculate_mass_ratio(rigidbody: RigidBody3D) -> float:
	return min(1.0, character_mass / rigidbody.mass)

func _calculate_final_force(mass_ratio: float, velocity_diff: float, push_dir: Vector3) -> Vector3:
	# Увеличим базовый множитель силы
	var force_multiplier = push_force_multiplier * 2.0  # Удвоили силу

	# Учитываем массу более агрессивно
	var mass_based_multiplier = sqrt(mass_ratio)  # Квадратный корень даёт лучшее распределение

	var horizontal_push = push_dir
	horizontal_push.y = 0
	horizontal_push = horizontal_push.normalized()

	var force = horizontal_push * velocity_diff * mass_based_multiplier * force_multiplier

	return force

func _apply_push_force(rigidbody: RigidBody3D, force: Vector3, position: Vector3) -> void:
	var apply_position = position - rigidbody.global_position
	rigidbody.apply_impulse(force, apply_position)

func _emit_push_signals(rigidbody: RigidBody3D, force_magnitude: float) -> void:
	SignalBus.rigidbody_pushed.emit(rigidbody, character_body, force_magnitude)

	# Эмитируем звуковой сигнал если превышен порог
	if enable_push_sounds and force_magnitude >= push_sound_threshold:
		SignalBus.push_sound_played.emit(
			character_body.global_position,
			force_magnitude,
			pusher_type
		)
