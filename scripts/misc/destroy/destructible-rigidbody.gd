extends RigidBody3D
class_name DestructibleRigidBody

@export_category("Destructible Settings")
@export_range(1, 10, 1) var max_health: int = 3
@export_range(1, 10, 1) var health: int = 3
@export_enum("wood", "stone", "metal") var physics_material_type: String = "wood"
@export var destroy_on_break: bool = true
@export var can_be_damaged_by_environment: bool = false

@export_category("Visual Settings")
@export var mesh_instance: MeshInstance3D
@export var damage_flash_color: Color = Color.WHITE
@export var damage_flash_duration: float = 0.15

@export_category("Effects & Sounds")
@export var break_effect: PackedScene
@export var break_sound: AudioStream
@export var hit_sound: AudioStream
@export var impact_sounds: Array[AudioStream]

@export_category("Physics Settings")
@export_range(0.1, 2.0, 0.1) var base_mass_multiplier: float = 1.0

# Приватные переменные
var _original_material: Material
var _is_flashing: bool = false
var _last_damage_source: Node = null
var _min_impact_force: float = 3.0

func _ready():
	health = max_health

	# Автоматически находим MeshInstance3D если не задан
	if not mesh_instance:
		mesh_instance = _find_mesh_instance()

	# Сохраняем оригинальный материал для эффектов
	if mesh_instance:
		_original_material = mesh_instance.get_surface_override_material(0)
		if _original_material:
			_original_material = _original_material.duplicate()

	# Настраиваем физические свойства
	_setup_physics_properties()

	# Подписываемся на сигналы повреждений
	SignalBus.player_attacked.connect(_on_player_attacked)

	# Настраиваем контактные отчеты для звуков столкновений
	contact_monitor = true
	max_contacts_reported = 2
	body_entered.connect(_on_body_entered)

func _find_mesh_instance() -> MeshInstance3D:
	for child in get_children():
		if child is MeshInstance3D:
			return child
	return null

func _setup_physics_properties() -> void:
	# Получаем данные материала из менеджера
	var material_data = PhysicsMaterialManager.get_material(physics_material_type)

	if material_data:
		# Устанавливаем массу через менеджер
		var base_mass = _get_base_mass_by_type()
		mass = material_data.get_mass(base_mass) * base_mass_multiplier

		# Создаем или настраиваем физический материал Godot
		if not physics_material_override:
			physics_material_override = PhysicsMaterial.new()

		# Настраиваем свойства физического материала из данных
		physics_material_override.friction = material_data.friction
		physics_material_override.bounce = material_data.bounciness

		# Сохраняем тип материала в метаданные для PushComponent
		set_meta("physics_material_type", physics_material_type)
		set_meta("physics_material_friction", material_data.friction)

		print("✅ Destructible с материалом '%s', масса: %.1f" % [physics_material_type, mass])
	else:
		push_error("❌ Физический материал '%s' не найден дляww destructible!" % physics_material_type)
		# Устанавливаем базовые значения если материал не найден
		mass = _get_base_mass_by_type() * base_mass_multiplier
		if not physics_material_override:
			physics_material_override = PhysicsMaterial.new()
		physics_material_override.friction = 0.4
		physics_material_override.bounciness = 0.2

func _get_base_mass_by_type() -> float:
	# Базовые массы в зависимости от типа объекта (не материала!)
	if "box" in name.to_lower():
		return Constants.MASS_BOX
	elif "barrel" in name.to_lower():
		return Constants.MASS_BARREL
	elif "rock" in name.to_lower() or "stone" in name.to_lower():
		return Constants.MASS_ROCK
	else:
		return Constants.MASS_BOX  # дефолт

func _on_body_entered(body: Node) -> void:
	# Воспроизводим звук удара если скорость достаточно высокая
	var impact_force = linear_velocity.length()

	if impact_force >= _min_impact_force:
		_play_impact_sound(impact_force)

		# Наносим урон от окружающей среды если включено
		if can_be_damaged_by_environment and health > 0:
			var environment_damage = _calculate_environment_damage(impact_force)
			if environment_damage > 0:
				_take_environment_damage(environment_damage, body)

func _play_impact_sound(impact_force: float) -> void:
	# Сначала проверяем свои звуки
	if not impact_sounds.is_empty():
		var volume = _calculate_impact_volume(impact_force)
		var random_sound = impact_sounds[randi() % impact_sounds.size()]
		SignalBus.play_sound_3d.emit(random_sound, global_position, volume)

	# Также отправляем сигнал для PhysicsAudioManager
	SignalBus.rigidbody_impact_sound.emit(
		global_position,
		impact_force,
		physics_material_type
	)

func _calculate_impact_volume(impact_force: float) -> float:
	var normalized_force = clamp(impact_force / 10.0, 0.0, 1.0)
	return lerp(-20.0, -8.0, normalized_force)

func _calculate_environment_damage(impact_force: float) -> int:
	# Урон от падения/столкновений
	if impact_force > 8.0:
		return 2
	elif impact_force > 5.0:
		return 1
	return 0

func _take_environment_damage(damage: int, source: Node) -> void:
	if health <= 0:
		return

	health -= damage
	_last_damage_source = source

	print("Ящик получил урон от окружения: ", damage, ". Здоровье: ", health, "/", max_health)

	# Эффект получения урона
	_play_hit_flash()

	# Звук попадания
	if hit_sound:
		SignalBus.play_sound_3d.emit(hit_sound, global_position, -12.0)

	# Сигнал о получении урона
	SignalBus.destructible_damaged.emit(self, damage, health, max_health)

	if health <= 0:
		_on_break()

# Обработчик атаки игрока через SignalBus
func _on_player_attacked(target: Node, damage: int) -> void:
	if target == self:
		take_hit(damage)

# Публичный метод для получения урона
func take_hit(damage: int = 1, source: Node = null) -> void:
	if health <= 0:
		return

	health -= damage
	_last_damage_source = source

	print("Ящик получил урон: ", damage, ". Здоровье: ", health, "/", max_health)

	# Визуальный эффект
	_play_hit_flash()

	# Звук попадания
	if hit_sound:
		SignalBus.play_sound_3d.emit(hit_sound, global_position, -10.0)

	# Отправляем сигналы через SignalBus
	SignalBus.destructible_damaged.emit(self, damage, health, max_health)

	if health <= 0:
		_on_break()

func _play_hit_flash() -> void:
	if _is_flashing or not mesh_instance or not _original_material:
		return

	_is_flashing = true

	# Создаем временный материал для вспышки
	var flash_material = _original_material.duplicate()

	# Настраиваем цвет вспышки в зависимости от материала
	var flash_color = damage_flash_color
	match physics_material_type:
		"metal":
			flash_color = Color.SILVER
		"stone":
			flash_color = Color.LIGHT_GRAY

	flash_material.albedo_color = flash_color
	mesh_instance.set_surface_override_material(0, flash_material)

	# Возвращаем оригинальный материал через время
	await get_tree().create_timer(damage_flash_duration).timeout

	if mesh_instance and is_instance_valid(self):
		mesh_instance.set_surface_override_material(0, _original_material)

	_is_flashing = false

func _on_break() -> void:
	print("Ящик уничтожен!")

	# Отправляем сигналы
	SignalBus.destructible_destroyed.emit(self)

	# Эффект разрушения
	if break_effect:
		SignalBus.spawn_effect.emit(break_effect, global_position, rotation)

	# Звук разрушения
	if break_sound:
		SignalBus.play_sound_3d.emit(break_sound, global_position, -6.0)

	if destroy_on_break:
		queue_free()

# Публичные геттеры для внешнего доступа
func get_health_percentage() -> float:
	return float(health) / float(max_health)

func is_destroyed() -> bool:
	return health <= 0

func get_material_type() -> String:
	return physics_material_type

# Метод для лечения/восстановления
func heal(amount: int) -> void:
	if health <= 0:
		return

	health = min(health + amount, max_health)
	print("Ящик восстановлен: ", health, "/", max_health)

	SignalBus.destructible_damaged.emit(self, 0, health, max_health)

# Обработчик для внешних сил (например, взрывов)
func apply_explosion_force(force: Vector3, pos: Vector3) -> void:
	apply_impulse(force, pos - global_position)

	# Дополнительный урон от взрыва
	var explosion_damage = int(force.length() / 10.0)
	if explosion_damage > 0:
		take_hit(explosion_damage)
