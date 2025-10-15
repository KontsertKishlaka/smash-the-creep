extends CharacterBody3D
class_name Slime

@export var speed: float = 1.0
@export var jump_velocity: float = 5.0
@export var gravity: float = 9.8
@export var detection_range: float = 10.0
@export var jump_distance: float = 10.0
@export var jump_cooldown: float = 1.5
@export var patrol_radius: float = 6.0
@export var rotation_smoothness: float = 4.0
@export var model_yaw_offset: float = 0.0
@export var player: Player

@export var patrol_jump_chance: float = 0.03

var jump_timer: float = 0.0
var patrol_target: Vector3
var state: String = "patrol"

func _ready():
	_set_new_patrol_target()
	randomize()


func _physics_process(delta: float):
	if not player:
		return

	jump_timer -= delta

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	match state:
		"patrol":
			_patrol(delta)
			if distance < detection_range:
				state = "chase"

		"chase":
			_chase_player(to_player, distance, delta)
			if distance > detection_range * 1.5:
				state = "patrol"
				_set_new_patrol_target()

	# гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0.0

	move_and_slide()


# ----------- ПАТРУЛЬ -----------

func _set_new_patrol_target():
	var random_offset = Vector3(
		randf_range(-patrol_radius, patrol_radius),
		0,
		randf_range(-patrol_radius, patrol_radius)
	)
	patrol_target = global_position + random_offset


func _patrol(delta: float):
	var to_target = patrol_target - global_position
	if to_target.length() < 0.5:
		_set_new_patrol_target()

	var dir = to_target.normalized()
	velocity.x = dir.x * speed * 0.5
	velocity.z = dir.z * speed * 0.5
	_rotate_toward(dir, delta)

	# 🟢 случайный прыжок во время патруля
	if is_on_floor() and jump_timer <= 0.0 and randf() < patrol_jump_chance:
		velocity.y = jump_velocity * randf_range(0.6, 1.5) # иногда чуть слабее
		jump_timer = jump_cooldown


# ----------- ПОГОНЯ -----------

func _chase_player(to_player: Vector3, distance: float, delta: float):
	var dir = to_player.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	_rotate_toward(dir, delta)

	if is_on_floor() and jump_timer <= 0.0 and distance < jump_distance:
		velocity.y = jump_velocity
		jump_timer = jump_cooldown


# ----------- ПОВОРОТ -----------

func _rotate_toward(direction: Vector3, delta: float):
	if direction.length() > 0.01:
		var target_angle = atan2(direction.x, direction.z)
		var desired = target_angle + model_yaw_offset
		rotation.y = lerp_angle(rotation.y, desired, delta * rotation_smoothness)
