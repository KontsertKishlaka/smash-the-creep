extends EnemyState
class_name TakeDamageState

@export var state_enum: int = EnemyStatesEnum.State.TakeDamageState

var _damage_source: Node
var _damage_direction: Vector3
var _knockback_power: float = 3.0
var _state_duration: float = 0.3
var _state_timer: float = 0.0

func enter(params: Array = []):
	if params.size() > 0 and params[0] is Node:
		_damage_source = params[0]
		_damage_direction = (slime.global_position - _damage_source.global_position).normalized()
	else:
		_damage_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	_state_timer = _state_duration
	
	slime.velocity = _damage_direction * _knockback_power + Vector3.UP * 2.0
	
	print("TakeDamageState: получение урона, отбрасывание")

func physics_update(delta: float):
	if not slime.data:
		return
	
	_state_timer -= delta
	
	slime.velocity.x = lerp(slime.velocity.x, 0.0, delta * 5.0)
	slime.velocity.z = lerp(slime.velocity.z, 0.0, delta * 5.0)
	slime.velocity.y -= slime.data.gravity * delta
	
	slime.move_and_slide()
	
	if _state_timer <= 0:
		_transition_from_damage()

func _transition_from_damage():
	if not slime.is_alive():
		state_machine.change_state(EnemyStatesEnum.State.DeathState)
	else:
		var distance_to_player = slime.global_position.distance_to(slime.player.global_position)
		
		if distance_to_player <= slime.data.attack_range:
			state_machine.change_state(EnemyStatesEnum.State.AttackState)
		elif distance_to_player <= slime.data.detection_range:
			state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		else:
			state_machine.change_state(EnemyStatesEnum.State.PatrolState)
