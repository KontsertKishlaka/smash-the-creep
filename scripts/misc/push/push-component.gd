extends Node
class_name PushComponent

@export_category("Push Configuration")
@export_range(10., 200., 5.) var character_mass: float = Constants.DEFAULT_CHARACTER_MASS
@export_range(.1, 20., .1) var push_force_multiplier: float = Constants.PUSH_FORCE_MULTIPLIER
@export_range(.1, 1., .05) var min_mass_ratio: float = Constants.MIN_MASS_RATIO
@export_range(.0, 2., .1) var velocity_decay: float = .8

@export_category("Advanced Settings")
@export var use_advanced_physics: bool = true
@export_range(.0, 1., .05) var friction_coefficient: float = .3
@export_range(.0, 1., .05) var restitution: float = .1

@export_category("Sound Configuration")
@export_enum("PLAYER", "ENEMY_SMALL", "ENEMY_MEDIUM", "ENEMY_LARGE") var pusher_type: String = "PLAYER"
@export var enable_push_sounds: bool = true
@export_range(.1, 10., .1) var push_sound_threshold: float = Constants.PUSH_SOUND_THRESHOLD

# Трекинг предыдущей позиции для точного определения направления
var _previous_global_position: Vector3
var _calculated_velocity: Vector3
var character_body: CharacterBody3D

func _ready() -> void:
	character_body = get_parent() as CharacterBody3D
	if not character_body:
		push_error("❌ 'PushComponent' должен быть дочерним компонентом 'CharacterBody3D'")

	_previous_global_position = character_body.global_position

func _physics_process(_delta: float) -> void:
	# Вычисляем скорость на основе изменения позиции
	_calculated_velocity = (character_body.global_position - _previous_global_position) / get_physics_process_delta_time()
	_previous_global_position = character_body.global_position

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
			if _handle_rigidbody_collision(collider, collision):
				pushed_count += 1

func _handle_rigidbody_collision(rigidbody: RigidBody3D, collision: KinematicCollision3D) -> bool:
	# Используем вычисленную скорость вместо velocity для большей точности
	var effective_velocity = _calculated_velocity
	var horizontal_velocity = Vector3(effective_velocity.x, 0, effective_velocity.z)

	# Определяем направление толкания более надежно
	var push_direction = _calculate_push_direction(horizontal_velocity, collision, rigidbody)

	if push_direction.length_squared() < 0.01:
		return false

	var velocity_diff = _calculate_velocity_difference(rigidbody, push_direction, effective_velocity)

	# Увеличиваем минимальную силу для более отзывчивого поведения
	if velocity_diff <= .2:
		velocity_diff = 1.5

	var mass_ratio = _calculate_mass_ratio(rigidbody)

	if mass_ratio < min_mass_ratio:
		return false

	var final_force = _calculate_final_force(mass_ratio, velocity_diff, push_direction, rigidbody)

	_apply_push_force(rigidbody, final_force, collision.get_position())
	_emit_push_signals(rigidbody, final_force.length())

	return true

func _calculate_push_direction(horizontal_velocity: Vector3, collision: KinematicCollision3D, rigidbody: RigidBody3D) -> Vector3:
	# Приоритет 1: направление движения персонажа
	if horizontal_velocity.length_squared() > 0.5:
		return horizontal_velocity.normalized()

	# Приоритет 2: направление от персонажа к объекту
	var to_rigidbody = rigidbody.global_position - character_body.global_position
	to_rigidbody.y = 0
	if to_rigidbody.length_squared() > 0.1:
		return to_rigidbody.normalized()

	# Приоритет 3: нормаль коллизии (fallback)
	var collision_normal = -collision.get_normal()
	collision_normal.y = 0
	if collision_normal.length_squared() > .1:
		return collision_normal.normalized()

	return Vector3.ZERO

func _calculate_velocity_difference(rigidbody: RigidBody3D, push_dir: Vector3, effective_velocity: Vector3) -> float:
	var character_vel_in_dir = effective_velocity.dot(push_dir)
	var rigidbody_vel_in_dir = rigidbody.linear_velocity.dot(push_dir)

	return max(0.0, character_vel_in_dir - rigidbody_vel_in_dir)

func _calculate_mass_ratio(rigidbody: RigidBody3D) -> float:
	return min(1.0, character_mass / rigidbody.mass)

func _calculate_final_force(mass_ratio: float, velocity_diff: float, push_dir: Vector3, rigidbody: RigidBody3D) -> Vector3:
	var base_force = push_force_multiplier

	if use_advanced_physics:
		# Учитываем физические свойства
		var material_multiplier = _get_material_multiplier(rigidbody)
		base_force *= material_multiplier

		# Учитываем трение
		var friction_effect = 1.0 - (friction_coefficient * 0.5)
		base_force *= friction_effect

	var mass_based_multiplier = sqrt(mass_ratio)
	var force_magnitude = velocity_diff * mass_based_multiplier * base_force

	var force = push_dir * force_magnitude
	force.y = 0  # Убираем вертикальную компоненту

	return force

func _get_material_multiplier(rigidbody: RigidBody3D) -> float:
	# Можно расширить для разных типов материалов
	if rigidbody.is_in_group(Constants.GROUP_DESTRUCTIBLES):
		return 1.2  # Деревянные ящики толкаются легче
	return 1.0

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
