extends EnemyState
class_name TakeDamageState

@export var state_enum: int = EnemyStatesEnum.State.TakeDamageState

var _damage_source: Node
var _damage_direction: Vector3
var _knockback_power: float = 3.0
var _state_duration: float = 0.3
var _state_timer: float = 0.0

var _invincibility_duration: float = 0.5
var _flash_timer: float = 0.0
var _is_flashing: bool = false
var _original_material: Material
var damage_amount: int = 0

@export var hit_flash_color: Color = Color(1.0, 0.3, 0.3, 1.0)
@export var max_knockback_power: float = 5.0
@export var min_knockback_power: float = 1.5

func enter(params: Array = []):
	if params.size() > 0 and params[0] is Node:
		_damage_source = params[0]
		_damage_direction = (slime.global_position - _damage_source.global_position).normalized()
	else:
		_damage_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	_state_timer = _state_duration
	_flash_timer = _invincibility_duration
	_is_flashing = true
	
	_calculate_knockback()
	
	_start_damage_effects()
	
	_play_damage_sound()
	
	print("TakeDamageState: получение урона, отбрасывание (сила: %.1f)" % _knockback_power)

func physics_update(delta: float):
	if not slime.data or not slime.player:
		_transition_from_damage()
		return
	
	_state_timer -= delta
	_flash_timer -= delta
	
	
	slime.velocity.x = lerp(slime.velocity.x, 0.0, delta * 5.0)
	slime.velocity.z = lerp(slime.velocity.z, 0.0, delta * 5.0)
	slime.velocity.y -= slime.data.gravity * delta
	
	if slime.is_on_floor():
		slime.velocity.x *= 0.8
		slime.velocity.z *= 0.8
	
	slime.move_and_slide()
	
	_check_wall_collisions()
	
	if _state_timer <= 0:
		_transition_from_damage()

func exit():
	_stop_damage_effects()
	_is_flashing = false

func _calculate_knockback():
	var base_knockback = _knockback_power
	
	if _damage_source and _damage_source is Player:
		base_knockback *= 1.5
	
	var variation = randf_range(0.8, 1.2)
	_knockback_power = clamp(base_knockback * variation, min_knockback_power, max_knockback_power)
	
	slime.velocity = _damage_direction * _knockback_power + Vector3.UP * 2.0

func _start_damage_effects():
	if _has_mesh_instance():
		_save_original_material()
	
	SignalBus.spawn_effect.emit(
		#preload("res://effects/hit_sparks.tscn"),
		slime.global_position + Vector3.UP * 0.5,
		_damage_direction
	)

func update_damage_effects(_delta: float):
	if _is_flashing and _has_mesh_instance():
		var flash_speed = 10.0
		var alpha = (sin(_flash_timer * flash_speed) + 1.0) * 0.5
		
		var fade_progress = 1.0 - (_flash_timer / _invincibility_duration)
		var final_alpha = lerp(alpha, 1.0, fade_progress)
		
		_apply_flash_color(final_alpha)

func _stop_damage_effects():
	if _has_mesh_instance() and _original_material:
		slime.mesh_instance.material_override = _original_material

func _play_damage_sound():
	SignalBus.play_sound_3d.emit(
		#preload("res://sounds/enemy_hit.wav"),
		slime.global_position,
		-5.0,
		"SFX"
	)

func _check_wall_collisions():
	if slime.get_slide_collision_count() > 0:
		var collision = slime.get_slide_collision(0)
		if collision:
			var normal = collision.get_normal()
			
			if abs(normal.y) < 0.7:
				slime.velocity = slime.velocity.bounce(normal) * 0.7
				print("TakeDamageState: отскочил от стены")

func _transition_from_damage():
	_stop_damage_effects()
	
	if not slime.is_alive():
		print("TakeDamageState: смерть от полученного урона")
		state_machine.change_state(EnemyStatesEnum.State.DeathState)
	else:
		var distance_to_player = slime.global_position.distance_to(slime.player.global_position)
		
		if _should_counter_attack():
			state_machine.change_state(EnemyStatesEnum.State.AttackState)
		elif distance_to_player <= slime.data.attack_range:
			state_machine.change_state(EnemyStatesEnum.State.AttackState)
		elif distance_to_player <= slime.data.detection_range:
			state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		else:
			state_machine.change_state(EnemyStatesEnum.State.PatrolState)

func _should_counter_attack() -> bool:
	if not slime.is_alive():
		return false
	
	var distance_to_player = slime.global_position.distance_to(slime.player.global_position)
	var base_chance = 0.3
	
	if distance_to_player < slime.data.attack_range * 1.5:
		base_chance = 0.6
	
	return randf() < base_chance

func _has_mesh_instance() -> bool:
	return slime and slime.has_node("MeshInstance3D")

func _save_original_material():
	var mesh = slime.get_node("MeshInstance3D")
	if mesh and mesh.material_override:
		_original_material = mesh.material_override.duplicate()

func _apply_flash_color(alpha: float):
	var mesh = slime.get_node("MeshInstance3D")
	if mesh and mesh.material_override:
		var current_color = hit_flash_color
		current_color.a = alpha
		mesh.material_override.albedo_color = current_color
