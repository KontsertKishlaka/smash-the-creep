extends CharacterBody3D
class_name Slime

# --- Данные врага ---
@export var data: EnemyData
@export var player: Player

# --- Узлы ---
@onready var health_system: HealthSystem = $HealthSystem
@onready var state_machine: Node = $StateMachine

# --- Внутренние переменные ---
var jump_timer: float = 0.0
var patrol_target: Vector3

func _ready():
	randomize()
	_set_new_patrol_target()
	
	if not data:
		printerr("Slime: EnemyData не назначен!")

	# Подписка на сигнал смерти
	health_system.connect("died", Callable(self, "_on_death"))

func _on_death():
	print("Слайм умер!")
	# TODO: добавить анимацию смерти
	queue_free()

func _physics_process(delta: float):
	if not data:
		return

	# --- Гравитация ---
	if not is_on_floor():
		velocity.y -= data.gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0.0

	# --- Движение выполняет StateMachine через velocity ---
	move_and_slide()

# ----------- Вспомогательные методы для состояний -----------

func _set_new_patrol_target():
	var random_offset = Vector3(
		randf_range(-data.patrol_radius, data.patrol_radius),
		0,
		randf_range(-data.patrol_radius, data.patrol_radius)
	)
	patrol_target = global_position + random_offset

func _rotate_toward(direction: Vector3, delta: float):
	if direction.length() > 0.01:
		var target_angle = atan2(direction.x, direction.z)
		var desired = target_angle + data.model_yaw_offset
		rotation.y = lerp_angle(rotation.y, desired, delta * data.rotation_smoothness)
