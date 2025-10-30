extends Node
class_name PushComponent

@export_category("Push Configuration")
@export_range(10.0, 200.0, 5.0) var character_mass: float = Constants.DEFAULT_CHARACTER_MASS
@export_range(0.1, 20.0, 0.1) var push_force_multiplier: float = Constants.PUSH_FORCE_MULTIPLIER
@export_range(0.1, 1.0, 0.05) var min_mass_ratio: float = Constants.MIN_MASS_RATIO

@export_category("Pusher Type")
@export_enum("PLAYER", "ENEMY") var pusher_type: String = "ENEMY"

@export_category("Sound Configuration")
@export var enable_push_sounds: bool = true
@export_range(0.1, 10.0, 0.1) var push_sound_threshold: float = Constants.PUSH_SOUND_THRESHOLD

var character_body: CharacterBody3D
var _previous_global_position: Vector3
var _calculated_velocity: Vector3

func _ready() -> void:
	character_body = get_parent() as CharacterBody3D
	if not character_body:
		push_error("❌ 'PushComponent' должен быть дочерним компонентом 'CharacterBody3D'")

	_previous_global_position = character_body.global_position

func _physics_process(_delta: float) -> void:
	_calculated_velocity = (character_body.global_position - _previous_global_position) / get_physics_process_delta_time()
	_previous_global_position = character_body.global_position

# Основной метод толкания - вызывается после move_and_slide()
func push_rigid_bodies() -> void:
	if not character_body:
		return

	var pushed_count: int = 0

	for i in character_body.get_slide_collision_count():
		var collision: KinematicCollision3D = character_body.get_slide_collision(i)
		var collider: Object = collision.get_collider()

		if collider is RigidBody3D:
			if _handle_rigidbody_collision(collider, collision):
				pushed_count += 1

func _handle_rigidbody_collision(rigidbody: RigidBody3D, collision: KinematicCollision3D) -> bool:
	var push_direction: Vector3 = _calculate_push_direction(collision, rigidbody)

	if push_direction.length_squared() < 0.01:
		return false

	var velocity_diff: float = _calculate_velocity_difference(rigidbody, push_direction)
	var mass_ratio: float = _calculate_mass_ratio(rigidbody)

	if velocity_diff <= 0.2 or mass_ratio < min_mass_ratio:
		return false

	var final_force: Vector3 = _calculate_final_force(mass_ratio, velocity_diff, push_direction)
	_apply_push_force(rigidbody, final_force, collision.get_position())
	_emit_push_signals(rigidbody, final_force.length())

	return true

func _calculate_push_direction(collision: KinematicCollision3D, rigidbody: RigidBody3D) -> Vector3:
	var horizontal_velocity := Vector3(_calculated_velocity.x, 0.0, _calculated_velocity.z)

	if horizontal_velocity.length_squared() > 0.5:
		return horizontal_velocity.normalized()

	var to_rigidbody: Vector3 = rigidbody.global_position - character_body.global_position
	to_rigidbody.y = 0.0

	if to_rigidbody.length_squared() > 0.1:
		return to_rigidbody.normalized()

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

func _calculate_final_force(mass_ratio: float, velocity_diff: float, push_dir: Vector3) -> Vector3:
	var mass_based_multiplier: float =  sqrt(mass_ratio)
	var force_magnitude: float = velocity_diff * mass_based_multiplier * push_force_multiplier
	return push_dir * force_magnitude

func _apply_push_force(rigidbody: RigidBody3D, force: Vector3, position: Vector3) -> void:
	var apply_position: Vector3 = position - rigidbody.global_position
	rigidbody.apply_impulse(force, apply_position)

func _emit_push_signals(rigidbody: RigidBody3D, force_magnitude: float) -> void:
	SignalBus.rigidbody_pushed.emit(rigidbody, character_body, force_magnitude)

	if enable_push_sounds and force_magnitude >= push_sound_threshold:
		SignalBus.push_sound_played.emit(
			character_body.global_position,
			force_magnitude,
			pusher_type
		)
