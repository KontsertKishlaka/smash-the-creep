extends PlayerState
class_name PlayerMoveState

var _footstep_timer: Timer
var _is_moving: bool = false
var _movement_speed: float

func enter() -> void:
	_is_moving = true
	_setup_footstep_timer()
	_footstep_timer.start()

func exit() -> void:
	_is_moving = false
	if _footstep_timer:
		_footstep_timer.stop()

func physics_process(delta: float) -> void:
	var input_dir: Vector3 = get_movement_input()

	if input_dir.length() == 0:
		state_machine.change_state(state_machine.get_state("IdleState"))
		return

	if _should_transition_to_other_state():
		return

	_handle_movement(delta, input_dir)
	_apply_gravity(delta)
	player.move_and_slide()

func _handle_movement(delta: float, input_dir: Vector3) -> void:
	var camera_relative_dir: Vector3 = player.get_camera_relative_direction(input_dir)
	var target_velocity: Vector3 = camera_relative_dir * _movement_speed

	var current_velocity := Vector2(player.velocity.x, player.velocity.z)
	var new_velocity: Vector2 = current_velocity.lerp(
		Vector2(target_velocity.x, target_velocity.z),
		_get_movement_acceleration() * delta
	)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

func _setup_footstep_timer() -> void:
	if _footstep_timer == null:
		_footstep_timer = Timer.new()
		_footstep_timer.wait_time = _get_footstep_interval()
		_footstep_timer.one_shot = false
		_footstep_timer.timeout.connect(_on_footstep)
		add_child(_footstep_timer)

func _on_footstep() -> void:
	if _is_moving and player.is_on_floor():
		audio_component.play_footstep()

# Абстрактные методы для переопределения в дочерних классах
func _get_movement_speed() -> float:
	return .0

func _get_movement_acceleration() -> float:
	return 10.0

func _get_footstep_interval() -> float:
	return .5

func _should_transition_to_other_state() -> bool:
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state(state_machine.get_state("JumpState"))
		return true

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_state("AttackState"))
		return true

	return false
