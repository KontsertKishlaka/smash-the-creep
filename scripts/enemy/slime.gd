extends CharacterBody3D
class_name Slime

@export var data: EnemyData
@export var player: Player

@onready var health_system: HealthSystem = $HealthSystem
@onready var state_machine: EnemyStateMachine = $StateMachine

var jump_timer: float = 0.0
var patrol_target: Vector3

func _ready():
	randomize()
	if not data:
		printerr("Slime: EnemyData не назначен!")
		return

	_set_new_patrol_target()
	health_system.connect("died", Callable(self, "_on_death"))

func _on_death():
	state_machine.change_state(EnemyStatesEnum.State.DeathState)

func _physics_process(delta):
	if not data:
		return

	if not is_on_floor():
		velocity.y -= data.gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0.0

	move_and_slide()

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
