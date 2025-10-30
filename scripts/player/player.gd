extends CharacterBody3D
class_name Player

@export_category("Player Resources")
@export var player_data: PlayerData
@export var player_config: PlayerConfig

@onready var camera: Camera3D = $Camera
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $Animation

# Добавляем систему здоровья
var health_system: HealthSystem

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup_hitbox()
	setup_health_system()

func setup_health_system():
	# Создаем HealthSystem для игрока
	var max_health = player_data.max_health if player_data else 100
	health_system = HealthSystem.new(self, "Player", max_health)
	
	# Подключаем сигналы
	SignalBus.health_changed.connect(_on_health_changed)
	SignalBus.invincibility_started.connect(_on_invincibility_started)
	SignalBus.invincibility_ended.connect(_on_invincibility_ended)

func setup_hitbox():
	var hitbox = $Camera/PivotArm/Mesh/Hitbox
	hitbox.collision_mask = Constants.LAYERS.ENEMY | Constants.LAYERS.DESTRUCTIBLE
	hitbox.monitoring = false

# Добавляем обработку здоровья в процесс
func _process(delta):
	if health_system:
		health_system.update(delta)

# Метод для получения направления движения относительно камеры
func _input(event):
	if event is InputEventMouseMotion:
		# Горизонтальное вращение игрока
		rotate_y(-event.relative.x * player_config.mouse_sensitivity)

		# Вертикальное вращение камеры с ограничениями
		if camera:
			var current_tilt = camera.rotation_degrees.x
			var tilt_change = -event.relative.y * player_config.mouse_sensitivity * 100
			var target_tilt = current_tilt + tilt_change
			target_tilt = clamp(target_tilt, -player_config.max_degree, player_config.max_degree)
			camera.rotation_degrees.x = target_tilt

# Метод для получения направления движения относительно камеры
func get_camera_relative_direction(local_direction: Vector3) -> Vector3:
	var direction = Vector3.ZERO

	# Преобразуем локальное направление в глобальное относительно камеры
	var camera_transform = camera.global_transform
	direction += camera_transform.basis.z * local_direction.z  # Вперед/назад
	direction += camera_transform.basis.x * local_direction.x  # Влево/вправо

	direction.y = 0
	return direction.normalized()

# Метод для получения урона
func take_damage(amount: int, source: Node = null):
	if health_system and health_system.is_alive():
		health_system.take_damage(amount, source)

# Обработчики сигналов здоровья
func _on_health_changed(entity: Node, current_health: int, max_health: int):
	if entity == self:
		print("Здоровье игрока: %d/%d" % [current_health, max_health])
		# Здесь можно обновить UI здоровья
		# update_health_ui(current_health, max_health)

func _on_invincibility_started(entity: Node, duration: float):
	if entity == self:
		print("Игрок неуязвим на %.1f секунд" % duration)
		# Можно добавить визуальный эффект неуязвимости
		# start_invincibility_effect()

func _on_invincibility_ended(entity: Node):
	if entity == self:
		print("Неуязвимость игрока закончилась")
		# Убрать визуальный эффект неуязвимости
		# stop_invincibility_effect()

# Метод для смерти игрока (будет вызван из HealthSystem)
func _on_death(_killer: Node = null):
	print("Игрок умер!")
	# Обработка смерти игрока
	SignalBus.game_over.emit()
	# state_machine.change_state("DeathState")
	# show_game_over_screen()
	
# Вспомогательные методы для доступа к состоянию здоровья
func get_current_health() -> int:
	return health_system.get_current_health() if health_system else 0

func get_max_health() -> int:
	return health_system.get_max_health() if health_system else 0

func is_alive() -> bool:
	return health_system.is_alive() if health_system else false

func is_invincible() -> bool:
	return health_system.is_invincible() if health_system else false

# Метод для лечения
func heal(amount: int):
	if health_system and health_system.is_alive():
		# Можно добавить логику лечения через HealthSystem
		# Пока что просто увеличиваем здоровье
		var new_health = min(health_system.get_current_health() + amount, health_system.get_max_health())
		health_system._current_health = new_health
		SignalBus.health_changed.emit(self, new_health, health_system.get_max_health())
