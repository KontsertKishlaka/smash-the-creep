extends EnemyState
class_name ChaseState

@export var state_enum: int = EnemyStatesEnum.State.ChaseState

var lost_player_timer: float = 0.0
var lost_player_duration: float = 1.5

func enter(_params: Array = []):
	lost_player_timer = 0.0

func physics_update(delta):
	if not slime.data or not slime.player:
		return

	var to_player = slime.player.global_position - slime.global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	slime.velocity.x = dir.x * slime.data.speed
	slime.velocity.z = dir.z * slime.data.speed
	slime._rotate_toward(dir, delta)

	if slime.is_on_floor() and slime.jump_timer <= 0.0 and distance < slime.data.jump_distance:
		slime.velocity.y = slime.data.jump_velocity
		slime.jump_timer = slime.data.jump_cooldown

	if slime.jump_timer > 0.0:
		slime.jump_timer -= delta

	if distance <= slime.data.attack_range:
		state_machine.change_state(EnemyStatesEnum.State.AttackState)
		return

	if distance > slime.data.detection_range:
		lost_player_timer += delta
		if lost_player_timer >= lost_player_duration:
			state_machine.change_state(EnemyStatesEnum.State.PatrolState)
	else:
		lost_player_timer = 0.0
