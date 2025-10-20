extends CharacterBody3D
class_name Slime

@export var data: EnemyData
@export var player: Player

@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: EnemyStateMachine = $StateMachine
@onready var land_sound: AudioStreamPlayer3D = $LandSound
@onready var jump_sound: AudioStreamPlayer3D = $JumpSound
@onready var damage_dealer: DamageDealer = $DamageDealer

var jump_timer: float = 0.0
var patrol_target: Vector3
var was_on_floor: bool = true  # для отслеживания касания пола

# --- Патрульная точка ---
func _set_new_patrol_target():
	var random_offset = Vector3(
		randf_range(-data.patrol_radius, data.patrol_radius),
		0,
		randf_range(-data.patrol_radius, data.patrol_radius)
	)
	patrol_target = global_position + random_offset

func _ready():
	randomize()
	if not data:
		printerr("Slime: EnemyData не назначен!")
		return

	_set_new_patrol_target()
	if health_component:
		health_component.connect("died", Callable(self, "_on_death"))
	else:
		printerr("Slime: HealthComponent not found!")

	if damage_dealer:
		damage_dealer.collision_mask = 1  # Player layer
	else:
		printerr("Slime: DamageDealer not found!")

func _on_death():
	state_machine.change_state(EnemyStatesEnum.State.DeathState)

# --- Основная физика с воспроизведением звуков ---
func _physics_process(delta):
	if not data or not player:  # Проверка на null
		return
	if not data:
		return

	# Сохраняем состояние пола до перемещения
	var was_on_floor_before = is_on_floor()

	# --- Гравитация ---
	if not is_on_floor():
		velocity.y -= data.gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0.0

	# --- Ограничение горизонтальной скорости ---
	var horiz_speed = Vector2(velocity.x, velocity.z).length()
	var max_allowed = max(data.speed * 6.0, data.speed)
	if horiz_speed > max_allowed:
		var factor = max_allowed / horiz_speed
		velocity.x *= factor
		velocity.z *= factor

	# --- Двигаемся ---
	move_and_slide()

	# --- Проверяем приземление и прыжок после move_and_slide ---
	var just_landed = not was_on_floor_before and is_on_floor()
	if just_landed:
		_play_land_sound()

	var just_jumped = was_on_floor_before and not is_on_floor() and velocity.y > 0.1
	if just_jumped:
		_play_jump_sound()

	was_on_floor = is_on_floor()

func _rotate_toward(direction: Vector3, delta: float):
	if direction.length() > 0.01:
		var target_angle = atan2(direction.x, direction.z)
		var desired = target_angle + data.model_yaw_offset
		rotation.y = lerp_angle(rotation.y, desired, delta * data.rotation_smoothness)

# --- Воспроизведение звука приземления ---
func _play_land_sound():
	if land_sound and not land_sound.playing:
		land_sound.pitch_scale = randf_range(0.9, 1.1)
		land_sound.play()

# --- Воспроизведение звука прыжка ---
func _play_jump_sound():
	if jump_sound and not jump_sound.playing:
		jump_sound.pitch_scale = randf_range(0.9, 1.1)
		jump_sound.play()
