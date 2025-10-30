extends EnemyState
class_name EnemyIdleState

@export var state_enum: int = EnemyStatesEnum.State.IdleState

# Настройки проверок
var check_timer: float = 0.0
var check_interval: float = 0.5

# Система осведомленности
var awareness_level: float = 0.0 
var max_awareness: float = 100.0
var awareness_decay_rate: float = 15.0

# Пассивное поведение
var passive_behavior_timer: float = 0.0
var passive_behavior_interval: float = 2.0

var last_player_position: Vector3 = Vector3.ZERO
var _last_visibility_check: bool = false

func enter(_params: Array = []):
	print("Enemy перешел в IdleState")
	
	check_timer = 0.0
	passive_behavior_timer = 0.0
	awareness_level = 0.0
	
	slime.velocity = Vector3.ZERO
	
	_play_idle_animation()

func physics_update(delta):
	check_timer += delta
	passive_behavior_timer += delta
	
	awareness_level = max(0.0, awareness_level - awareness_decay_rate * delta)
	
	if check_timer >= check_interval:
		check_timer = 0.0
		_perform_awareness_check()
	
	if passive_behavior_timer >= passive_behavior_interval:
		passive_behavior_timer = 0.0
		_perform_passive_behavior()
	
	if awareness_level >= 80.0:
		print("Enemy активирован! Уровень осведомленности: ", awareness_level)
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)

func _perform_awareness_check():
	if not slime.player or not is_instance_valid(slime.player):
		return
	
	var new_awareness = _calculate_awareness()
	
	awareness_level = lerp(awareness_level, new_awareness, 0.4)
	
	if new_awareness > awareness_level:
		_on_awareness_increased()

func _calculate_awareness() -> float:
	if not slime.player:
		return 0.0
	
	var awareness = 0.0
	var player_pos = slime.player.global_position
	var enemy_pos = slime.global_position
	
	var distance = enemy_pos.distance_to(player_pos)
	var distance_factor = 1.0 - (distance / slime.data.detection_range)
	awareness += distance_factor * 30.0
	
	if _has_direct_line_of_sight():
		awareness += 50.0
		_last_visibility_check = true
	else:
		_last_visibility_check = false
	
	awareness += _calculate_player_noise_level()
	
	if _is_in_same_zone():
		awareness += 20.0
	
	awareness += _get_recent_interaction_bonus()
	
	return clamp(awareness, 0.0, max_awareness)

func _has_direct_line_of_sight() -> bool:
	if not slime.player:
		return false
	
	var space_state = slime.get_world_3d().direct_space_state
	var from = slime.global_position + Vector3.UP * 0.5
	var to = slime.player.global_position + Vector3.UP * 1.0
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [slime]
	
	query.collision_mask = Constants.COLLISION_LAYER.WORLD
	
	var result = space_state.intersect_ray(query)
	

	return result.is_empty()

func _calculate_player_noise_level() -> float:
	if not slime.player:
		return 0.0
	
	var noise = 0.0
	var player = slime.player
	
	var player_speed = player.velocity.length()
	
	if player.player_data:
		if player_speed > player.player_data.run_speed * 0.9:
			noise += 25.0
		elif player_speed > player.player_data.walk_speed * 0.8:
			noise += 15.0
	else:
		if player_speed > 7.0:
			noise += 25.0
		elif player_speed > 4.0:
			noise += 15.0
	
	if player.has_method("is_attacking") and player.is_attacking:
		noise += 35.0
	
	if player.has_method("just_took_damage") and player.just_took_damage:
		noise += 45.0
	
	var distance = slime.global_position.distance_to(player.global_position)
	var distance_penalty = 1.0 - (distance / (slime.data.detection_range * 1.5))
	noise *= clamp(distance_penalty, 0.1, 1.0)
	
	return noise

func _is_in_same_zone() -> bool:
	if not slime.player:
		return false
	
	var distance = slime.global_position.distance_to(slime.player.global_position)
	return distance < slime.data.detection_range * 0.7

func _get_recent_interaction_bonus() -> float:
	var bonus = 0.0
	
	if slime.has_method("was_recently_attacked_by_player") and slime.was_recently_attacked_by_player():
		bonus += 40.0
	
	return bonus

func _perform_passive_behavior():
	if awareness_level < 30.0:
		if randf() < 0.3:
			_play_idle_sound()
		
		if randf() < 0.2:
			_play_idle_animation()
	
	elif awareness_level < 60.0:
		if randf() < 0.4:
			_play_alert_sound()
		
		if randf() < 0.3:
			_play_uneasy_animation()

func _play_idle_sound():
	if slime.land_sound and not slime.land_sound.playing:
		slime.land_sound.pitch_scale = randf_range(0.7, 0.9)
		slime.land_sound.volume_db = -10.0
		slime.land_sound.play()

func _play_alert_sound():
	if slime.jump_sound and not slime.jump_sound.playing:
		slime.jump_sound.pitch_scale = randf_range(1.0, 1.3)
		slime.jump_sound.play()

func _play_idle_animation():
	var tween = create_tween()
	tween.tween_property(slime, "scale", slime.original_scale * 1.05, 0.8)
	tween.tween_property(slime, "scale", slime.original_scale, 0.8)

func _play_uneasy_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(slime, "scale:y", slime.original_scale.y * 1.1, 0.3)
	tween.tween_property(slime, "scale:x", slime.original_scale.x * 0.95, 0.3)
	tween.tween_property(slime, "scale:z", slime.original_scale.z * 0.95, 0.3)
	
	var tween2 = create_tween()
	tween2.tween_property(slime, "scale", slime.original_scale, 0.5)

func _on_awareness_increased():
	if awareness_level > 50.0 and awareness_level < 80.0:
		_play_uneasy_animation()

func exit():
	slime.scale = slime.original_scale
	
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid() and tween.get_target() == slime:
			tween.kill()

func _quick_distance_check() -> bool:
	if not slime.player:
		return false
	return slime.global_position.distance_to(slime.player.global_position) <= slime.data.detection_range

func get_awareness_percentage() -> float:
	return awareness_level / max_awareness

func is_alerted() -> bool:
	return awareness_level > 40.0
