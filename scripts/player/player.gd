extends CharacterBody3D
class_name Player

@export_category("Player Resources")
@export var player_data: PlayerData
@export var player_config: PlayerConfig

@onready var camera: Camera3D = $Camera
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $Animation

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup_hitbox()

func setup_hitbox():
	var hitbox = $Camera/PivotArm/Mesh/Hitbox
	hitbox.collision_mask = Constants.LAYERS.ENEMY | Constants.LAYERS.DESTRUCTIBLE
	hitbox.monitoring = false

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
	direction += camera_transform.basis.x * local_direction.x   # Влево/вправо

	direction.y = 0
	return direction.normalized()
