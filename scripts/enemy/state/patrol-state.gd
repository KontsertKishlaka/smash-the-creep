extends EnemyState
class_name PatrolState

@export var state_enum: int = EnemyStatesEnum.State.PatrolState

var _stuck_timer: float = 0.0
var _stuck_duration: float = 3.0
var _last_position: Vector3
var _idle_timer: float = 0.0
var idle_duration: float = 2.0
var _is_idle: bool = false

var _wall_hit_timer: float = 0.0
var _wall_hit_cooldown: float = 1.0
var _collision_count: int = 0
var _last_collision_normal: Vector3

func enter(_params: Array = []):
	slime._set_new_patrol_target()
	slime.jump_timer = 0.0
	_stuck_timer = 0.0
	_idle_timer = 0.0
	_is_idle = false
	_last_position = slime.global_position
	_wall_hit_timer = 0.0
	_collision_count = 0
	
	print("PatrolState: начал патрулирование")

func physics_update(delta):
	if not slime.data or not slime.player:
		return

	if slime.jump_timer > 0.0:
		slime.jump_timer -= delta

	if _wall_hit_timer > 0.0:
		_wall_hit_timer -= delta

	_check_if_stuck(delta)

	_check_wall_collisions()

	if _is_idle:
		_idle_timer -= delta
		if _idle_timer <= 0:
			_is_idle = false
			slime._set_new_patrol_target()
			print("PatrolState: закончил ожидание, иду к новой точке")
		return

	var to_target = slime.patrol_target - slime.global_position
	var distance_to_target = to_target.length()
	
	if distance_to_target < 1.0 or _passed_target(to_target, slime.velocity):
		_start_idle_phase()
		return

	var dir = to_target.normalized()

	if _wall_hit_timer > 0 and _last_collision_normal != Vector3.ZERO:
		dir = _avoid_wall_direction(dir, _last_collision_normal)
	
	var speed_multiplier = _get_speed_multiplier(distance_to_target)
	slime.velocity.x = dir.x * slime.data.speed * 0.5 * speed_multiplier
	slime.velocity.z = dir.z * slime.data.speed * 0.5 * speed_multiplier
	
	slime._rotate_toward(dir, delta)

	if (slime.is_on_floor() and 
		slime.jump_timer <= 0.0 and 
		randf() < slime.data.patrol_jump_chance):
		
		var jump_strength = randf_range(slime.data.patrol_jump_min, slime.data.patrol_jump_max)
		slime.velocity.y = slime.data.jump_velocity * jump_strength
		slime.jump_timer = slime.data.jump_cooldown
		print("PatrolState: случайный прыжок (сила: %.2f)" % jump_strength)

	if _can_see_player():
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)

func _check_if_stuck(delta: float):
	var current_pos = slime.global_position
	var moved_distance = (current_pos - _last_position).length()
	
	if moved_distance < 0.1:
		_stuck_timer += delta
	else:
		_stuck_timer = 0.0
		_last_position = current_pos
	
	if _stuck_timer >= _stuck_duration:
		print("PatrolState: застрял, выбираю новую цель")
		slime._set_new_patrol_target()
		_stuck_timer = 0.0

func _check_wall_collisions():
	if slime.get_slide_collision_count() > 0:
		var collision = slime.get_slide_collision(0)
		if collision:
			var normal = collision.get_normal()
			
			if abs(normal.y) < 0.7:
				_collision_count += 1
				_last_collision_normal = normal
				
				if _collision_count >= 2 and _wall_hit_timer <= 0:
					print("PatrolState: обнаружена стена, меняю направление")
					_handle_wall_collision(normal)
					_wall_hit_timer = _wall_hit_cooldown
	else:
		_collision_count = 0

func _handle_wall_collision(wall_normal: Vector3):
	var avoid_direction = _get_avoid_direction(wall_normal)
	
	var new_target = slime.global_position + avoid_direction * slime.data.patrol_radius
	slime.patrol_target = Vector3(new_target.x, slime.global_position.y, new_target.z)
	
	print("PatrolState: новое направление обхода стены")

func _get_avoid_direction(wall_normal: Vector3) -> Vector3:
	var wall_direction = Vector3(wall_normal.x, 0, wall_normal.z).normalized()
	
	var random_side = 1.0 if randf() > 0.5 else -1.0
	
	var avoid_angle = deg_to_rad(randf_range(60, 120)) * random_side
	var avoid_direction = wall_direction.rotated(Vector3.UP, avoid_angle)
	
	return avoid_direction.normalized()

func _avoid_wall_direction(original_dir: Vector3, wall_normal: Vector3) -> Vector3:
	var avoid_dir = _get_avoid_direction(wall_normal)
	var blend_factor = 0.7
	
	return original_dir.lerp(avoid_dir, blend_factor).normalized()

func _start_idle_phase():
	_is_idle = true
	_idle_timer = randf_range(1.0, 3.0)
	slime.velocity.x = 0
	slime.velocity.z = 0
	print("PatrolState: достиг цели, ожидание ", _idle_timer, " сек")

func _passed_target(to_target: Vector3, velocity: Vector3) -> bool:
	if velocity.length() < 0.1:
		return false
	
	var move_direction = velocity.normalized()
	var target_direction = to_target.normalized()
	
	return move_direction.dot(target_direction) < 0

func _get_speed_multiplier(distance_to_target: float) -> float:
	if distance_to_target < 2.0:
		return 0.3
	elif distance_to_target < 4.0:
		return 0.6
	else:
		return 1.0

func _can_see_player() -> bool:
	var distance = (slime.player.global_position - slime.global_position).length()
	
	if distance > slime.data.detection_range:
		return false
	
	var space_state = slime.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		slime.global_position + Vector3.UP * 0.5,
		slime.player.global_position + Vector3.UP * 0.5
	)
	query.exclude = [slime]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.collider == slime.player
	else:
		return distance < slime.data.detection_range
