extends Node
class_name PushComponent

@export_category("Push Configuration")
@export_range(10.0, 200.0, 5.0) var character_mass: float = 80.0
@export_range(0.1, 20.0, 0.1) var push_force_multiplier: float = 5.0
@export_range(0.1, 1.0, 0.05) var min_mass_ratio: float = 0.25

@export_category("Pusher Configuration")
@export_enum("PLAYER", "ENEMY", "OTHER") var pusher_type: String = "PLAYER"
@export var can_push: bool = true
@export var push_enemies: bool = false

@export_category("Advanced Settings")
@export var use_advanced_physics: bool = true
@export_range(1.0, 100.0, 1.0) var max_push_force: float = 50.0
@export var debug_visualization: bool = false

@export_category("Sound Settings")
@export var enable_push_sounds: bool = true
@export_range(0.1, 10.0, 0.1) var push_sound_threshold: float = 2.0

var character_body: CharacterBody3D
var _previous_global_position: Vector3
var _calculated_velocity: Vector3
var _is_active: bool = true
var _debug_material: StandardMaterial3D

func _ready() -> void:
	character_body = get_parent() as CharacterBody3D
	if not character_body:
		push_error("❌ PushComponent must be a child of CharacterBody3D")
		return

	_previous_global_position = character_body.global_position

	# Автоматическая настройка в зависимости от типа
	_setup_by_pusher_type()

	# Подписка на изменения состояния если есть state machine
	_setup_state_machine_listener()

	# Настройка дебаг визуализации
	if debug_visualization:
		_setup_debug_material()

func _setup_by_pusher_type() -> void:
	match pusher_type:
		"PLAYER":
			character_mass = Constants.MASS_PLAYER
			push_force_multiplier = Constants.PUSH_FORCE_MULTIPLIER
		"ENEMY":
			character_mass = Constants.MASS_SLIME
			push_force_multiplier = Constants.PUSH_FORCE_MULTIPLIER * 0.7  # Враги толкают слабее
			push_enemies = false  # Враги обычно не толкают друг друга

func _setup_state_machine_listener() -> void:
	# Ищем StateMachine в родителе или его детях
	var state_machine = _find_state_machine()
	if state_machine and state_machine.has_signal("state_changed"):
		if not state_machine.state_changed.is_connected(_on_state_changed):
			state_machine.state_changed.connect(_on_state_changed)
	elif state_machine and state_machine.has_method("connect"):
		# Альтернативный способ подписки для кастомных state machine
		if state_machine.has_signal("state_changed"):
			state_machine.state_changed.connect(_on_state_changed)

func _find_state_machine() -> Node:
	# Ищем StateMachine в родителе или его детях
	if character_body.has_node("StateMachine"):
		return character_body.get_node("StateMachine")

	# Ищем по имени класса
	for child in character_body.get_children():
		if "StateMachine" in child.name or "state_machine" in child.name:
			return child
		if child.has_method("change_state"):  # Характерный метод для state machine
			return child

	return null

func _physics_process(_delta: float) -> void:
	if not _is_active or not can_push or not character_body:
		return

	# Рассчитываем скорость на основе изменения позиции
	# Это более точно чем velocity, т.к. velocity может сбрасываться
	_calculated_velocity = (character_body.global_position - _previous_global_position) / get_physics_process_delta_time()
	_previous_global_position = character_body.global_position

# Основной метод толкания - вызывается после move_and_slide()
func push_rigid_bodies() -> void:
	if not _is_active or not can_push or not character_body:
		return

	var pushed_count: int = 0

	for i in character_body.get_slide_collision_count():
		var collision: KinematicCollision3D = character_body.get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody3D:
			if _handle_rigidbody_collision(collider, collision):
				pushed_count += 1
		elif push_enemies and collider is CharacterBody3D and collider != character_body:
			# Опционально: толкание других CharacterBody3D (например, врагов)
			_handle_character_collision(collider, collision)

	if debug_visualization and pushed_count > 0:
		_show_debug_push(pushed_count)

func _handle_rigidbody_collision(rigidbody: RigidBody3D, collision: KinematicCollision3D) -> bool:
	var push_direction: Vector3 = _calculate_push_direction(collision, rigidbody)

	if push_direction.length_squared() < 0.01:
		return false

	var velocity_diff: float = _calculate_velocity_difference(rigidbody, push_direction)
	var mass_ratio: float = _calculate_mass_ratio(rigidbody)

	# Проверяем минимальные условия для толкания
	if velocity_diff <= 0.1 or mass_ratio < min_mass_ratio:
		return false

	var final_force: Vector3 = _calculate_final_force(mass_ratio, velocity_diff, push_direction, rigidbody)
	_apply_push_force(rigidbody, final_force, collision.get_position())
	_emit_push_signals(rigidbody, final_force.length(), collision)

	return true

func _handle_character_collision(character: CharacterBody3D, collision: KinematicCollision3D) -> void:
	# Базовое толкание других CharacterBody3D (например, для PvP или врагов)
	var push_direction: Vector3 = -collision.get_normal()
	push_direction.y = 0

	if push_direction.length_squared() > 0.1:
		push_direction = push_direction.normalized()
		var force_magnitude: float = _calculated_velocity.length() * 0.3
		character.velocity += push_direction * force_magnitude

func _calculate_push_direction(collision: KinematicCollision3D, rigidbody: RigidBody3D) -> Vector3:
	# Приоритет 1: горизонтальная скорость персонажа
	var horizontal_velocity := Vector3(_calculated_velocity.x, 0.0, _calculated_velocity.z)

	if horizontal_velocity.length_squared() > 0.5:
		return horizontal_velocity.normalized()

	# Приоритет 2: направление к RigidBody
	var to_rigidbody: Vector3 = rigidbody.global_position - character_body.global_position
	to_rigidbody.y = 0.0

	if to_rigidbody.length_squared() > 0.1:
		return to_rigidbody.normalized()

	# Приоритет 3: нормаль столкновения
	var collision_normal: Vector3 = -collision.get_normal()
	collision_normal.y = 0.0

	if collision_normal.length_squared() > 0.1:
		return collision_normal.normalized()

	return Vector3.ZERO

func _calculate_velocity_difference(rigidbody: RigidBody3D, push_dir: Vector3) -> float:
	var character_vel_in_dir: float = _calculated_velocity.dot(push_dir)
	var rigidbody_vel_in_dir: float = rigidbody.linear_velocity.dot(push_dir)
	return maxf(0.0, character_vel_in_dir - rigidbody_vel_in_dir)

func _calculate_mass_ratio(rigidbody: RigidBody3D) -> float:
	return minf(1.0, character_mass / rigidbody.mass)

func _calculate_final_force(mass_ratio: float, velocity_diff: float, push_dir: Vector3, rigidbody: RigidBody3D) -> Vector3:
	var mass_based_multiplier: float = sqrt(mass_ratio)
	var force_magnitude: float = velocity_diff * mass_based_multiplier * push_force_multiplier

	# Учет физических материалов если включена продвинутая физика
	if use_advanced_physics:
		var material_friction = _get_collision_material_friction(rigidbody)
		force_magnitude *= (1.0 - material_friction * 0.3)  # Уменьшение силы для высокого трения

	# Ограничение максимальной силы
	force_magnitude = min(force_magnitude, max_push_force)

	return push_dir * force_magnitude

func _get_collision_material_friction(rigidbody: RigidBody3D) -> float:
	# Приоритет 1: физический материал RigidBody
	if rigidbody.physics_material_override:
		return rigidbody.physics_material_override.friction

	# Приоритет 2: менеджер материалов через метаданные
	if rigidbody.has_meta("physics_material_type"):
		var material_type = rigidbody.get_meta("physics_material_type")
		return PhysicsMaterialManager.get_friction(material_type)

	# Приоритет 3: менеджер материалов через имя объекта
	if "wood" in rigidbody.name.to_lower() or "box" in rigidbody.name.to_lower():
		return PhysicsMaterialManager.get_friction("wood")
	elif "metal" in rigidbody.name.to_lower() or "barrel" in rigidbody.name.to_lower():
		return PhysicsMaterialManager.get_friction("metal")
	elif "stone" in rigidbody.name.to_lower() or "rock" in rigidbody.name.to_lower():
		return PhysicsMaterialManager.get_friction("stone")

	# Дефолтное трение
	return 0.4

func _apply_push_force(rigidbody: RigidBody3D, force: Vector3, position: Vector3) -> void:
	var apply_position: Vector3 = position - rigidbody.global_position
	rigidbody.apply_impulse(force, apply_position)

func _emit_push_signals(rigidbody: RigidBody3D, force_magnitude: float, collision: KinematicCollision3D) -> void:
	SignalBus.rigidbody_pushed.emit(rigidbody, character_body, force_magnitude)

	if enable_push_sounds and force_magnitude >= push_sound_threshold:
		SignalBus.push_sound_played.emit(
			collision.get_position(),
			force_magnitude,
			pusher_type
		)

func _on_state_changed(_old_state: String, new_state: String) -> void:
	# Отключаем толкание в определенных состояниях
	var no_push_states = [Constants.STATE_DEATH, Constants.STATE_TAKE_DAMAGE]
	_is_active = not no_push_states.has(new_state)

	if debug_visualization:
		print("PushComponent: State changed to ", new_state, " - Active: ", _is_active)

func set_active(active: bool) -> void:
	_is_active = active

func set_can_push(can_push_new: bool) -> void:
	can_push = can_push_new

# Дебаг визуализация
func _setup_debug_material() -> void:
	_debug_material = StandardMaterial3D.new()
	_debug_material.flags_unshaded = true
	_debug_material.vertex_color_use_as_albedo = true

func _show_debug_push(count: int) -> void:
	# В будущем можно добавить визуализацию сил толкания
	print("Pushed ", count, " rigid bodies with force: ", _calculated_velocity.length())

# Публичные геттеры для отладки
func get_current_velocity() -> Vector3:
	return _calculated_velocity

func is_pushing() -> bool:
	return _is_active and can_push
