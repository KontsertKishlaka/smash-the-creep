extends EnemyState
class_name ChaseState

@export var state_enum: int = EnemyStatesEnum.State.ChaseState

var lost_player_timer: float = 0.0
var lost_player_duration: float = 1.5

var _last_known_player_position: Vector3
var _search_timer: float = 0.0
var _wall_avoid_timer: float = 0.0
var _last_collision_normal: Vector3
var _prediction_timer: float = 0.0

func enter(_params: Array = []):
	lost_player_timer = 0.0
	_search_timer = 0.0
	_wall_avoid_timer = 0.0
	_last_known_player_position = Vector3.ZERO
	_last_collision_normal = Vector3.ZERO
	_prediction_timer = 0.0

func physics_update(delta):
	if not slime.data or not slime.player:
		return

	if slime.jump_timer > 0.0:
		slime.jump_timer -= delta

	if _wall_avoid_timer > 0.0:
		_wall_avoid_timer -= delta

	_prediction_timer += delta

	_check_wall_collisions()

	var to_player = slime.player.global_position - slime.global_position
	var distance = to_player.length()

	var predicted_dir = _get_predicted_direction(to_player)
	var final_dir = predicted_dir
	
	if _wall_avoid_timer > 0 and _last_collision_normal != Vector3.ZERO:
		final_dir = _avoid_wall_direction(final_dir, _last_collision_normal)

	slime.velocity.x = final_dir.x * slime.data.speed
	slime.velocity.z = final_dir.z * slime.data.speed
	slime._rotate_toward(final_dir, delta)

	if (slime.is_on_floor() and 
		slime.jump_timer <= 0.0 and 
		distance < slime.data.jump_distance and
		randf() < 0.3):
		
		var chase_jump_multiplier = 1.2
		slime.velocity.y = slime.data.jump_velocity * chase_jump_multiplier
		slime.jump_timer = slime.data.jump_cooldown * 0.8
	
	if distance <= slime.data.attack_range:
		state_machine.change_state(EnemyStatesEnum.State.AttackState)
		return

	if distance > slime.data.detection_range:
		lost_player_timer += delta
		_search_timer += delta
		
		if _search_timer >= 0.3:
			_last_known_player_position = slime.player.global_position
			_search_timer = 0.0
		
		if _last_known_player_position != Vector3.ZERO:
			var to_last_known = _last_known_player_position - slime.global_position
			if to_last_known.length() > 1.0:
				var last_known_dir = to_last_known.normalized()
				slime.velocity.x = last_known_dir.x * slime.data.speed * 0.8
				slime.velocity.z = last_known_dir.z * slime.data.speed * 0.8
				slime._rotate_toward(last_known_dir, delta)
		
		if lost_player_timer >= lost_player_duration:
			state_machine.change_state(EnemyStatesEnum.State.PatrolState)
	else:
		lost_player_timer = 0.0
		_last_known_player_position = Vector3.ZERO

func _get_predicted_direction(to_player: Vector3) -> Vector3:
	var current_dir = to_player.normalized()
	
	if _prediction_timer < 0.2:
		return current_dir
	
	_prediction_timer = 0.0
	
	var player_velocity = Vector3.ZERO
	if slime.player is CharacterBody3D:
		player_velocity = slime.player.velocity
	
	var prediction_time = 0.5
	var predicted_position = slime.player.global_position + player_velocity * prediction_time
	
	var max_prediction_distance = slime.data.detection_range * 1.5
	var to_predicted = predicted_position - slime.global_position
	if to_predicted.length() > max_prediction_distance:
		predicted_position = slime.global_position + current_dir * max_prediction_distance
	
	var predicted_dir = (predicted_position - slime.global_position).normalized()
	
	var prediction_blend = 0.7
	return current_dir.lerp(predicted_dir, prediction_blend).normalized()

func _check_wall_collisions():
	if slime.get_slide_collision_count() > 0:
		var collision = slime.get_slide_collision(0)
		if collision:
			var normal = collision.get_normal()

			if abs(normal.y) < 0.7:
				_last_collision_normal = normal
				_wall_avoid_timer = 0.5

func _avoid_wall_direction(original_dir: Vector3, wall_normal: Vector3) -> Vector3:
	var wall_direction = Vector3(wall_normal.x, 0, wall_normal.z).normalized()
	var random_side = 1.0 if randf() > 0.5 else -1.0
	var avoid_angle = deg_to_rad(randf_range(45, 90)) * random_side
	var avoid_direction = wall_direction.rotated(Vector3.UP, avoid_angle)

	return original_dir.lerp(avoid_direction, 0.6).normalized()
