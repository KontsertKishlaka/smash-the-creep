extends EnemyState
class_name PatrolState

@export var state_enum: int = EnemyStatesEnum.State.PatrolState

func enter(_params: Array = []):
	slime._set_new_patrol_target()
	slime.jump_timer = 0.0

func physics_update(delta):
	if not slime.data or not slime.player:
		return

	if slime.jump_timer > 0.0:
		slime.jump_timer -= delta

	var to_target = slime.patrol_target - slime.global_position
	if to_target.length() < 0.5:
		slime._set_new_patrol_target()

	var dir = to_target.normalized()
	slime.velocity.x = dir.x * slime.data.speed * 0.5
	slime.velocity.z = dir.z * slime.data.speed * 0.5
	slime._rotate_toward(dir, delta)

	if slime.is_on_floor() and slime.jump_timer <= 0.0 and randf() < slime.data.patrol_jump_chance:
		var jump_strength = randf_range(slime.data.patrol_jump_min, slime.data.patrol_jump_max)
		slime.velocity.y = slime.data.jump_velocity * jump_strength
		slime.jump_timer = slime.data.jump_cooldown

	var distance = (slime.player.global_position - slime.global_position).length()
	if distance < slime.data.detection_range:
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
