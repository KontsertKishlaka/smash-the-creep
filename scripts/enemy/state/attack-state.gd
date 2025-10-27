extends EnemyState
class_name EnemyAttackState

@export var state_enum: int = EnemyStatesEnum.State.AttackState

var attacking_air: bool = false
var is_bouncing: bool = false
var post_attack_delay_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var target: Node3D = null

func enter():
	if slime.player and is_instance_valid(slime.player):
		target = slime.player
	else:
		target = null

	attacking_air = true
	is_bouncing = false
	post_attack_delay_timer = 0.0
	attack_cooldown_timer = 0.0

	_request_attack_jump()


func physics_update(delta):
	if not slime.data or not slime or not is_instance_valid(slime):
		return

	if is_bouncing:
		_update_bounce(delta)
		return

	if not target or not is_instance_valid(target):
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		return

	var to_target = target.global_position - slime.global_position
	var distance = to_target.length()
	if attacking_air:
		var dir = to_target
		dir.y = 0
		dir = dir.normalized()

		slime.velocity.x = dir.x * slime.data.speed * 0.75
		slime.velocity.z = dir.z * slime.data.speed * 0.75
		slime.velocity.y -= slime.data.gravity * delta

		slime._rotate_toward(dir, delta)

		if distance <= slime.data.attack_range or slime.is_on_floor():
			_perform_attack()
			post_attack_delay_timer = 0.08
			attacking_air = false
			return

	if post_attack_delay_timer > 0.0:
		post_attack_delay_timer -= delta
		slime.velocity.y -= slime.data.gravity * delta
		return

	_start_bounce()


func _request_attack_jump():
	if target and is_instance_valid(target):
		var to_player = target.global_position - slime.global_position
		to_player.y = 0
		var dir = to_player.normalized()

		slime.velocity.x = dir.x * slime.data.speed * 0.9
		slime.velocity.z = dir.z * slime.data.speed * 0.9
		slime.velocity.y = slime.data.attack_jump_velocity * 1.1

	attacking_air = true


func _perform_attack():
	if attack_cooldown_timer > 0.0 or not is_instance_valid(target):
		return

	if target.has_method("take_damage"):
		target.take_damage(slime.data.attack_damage, slime)

	attack_cooldown_timer = slime.data.attack_cooldown


func _start_bounce():
	if not is_instance_valid(target):
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		return

	var away = slime.global_position - target.global_position
	away.y = 0
	away = away.normalized()

	slime.velocity = Vector3.ZERO

	var horiz = slime.data.attack_jump_velocity * slime.data.attack_knockback_horizontal
	var vert  = slime.data.attack_jump_velocity * slime.data.attack_knockback_vertical * 0.35

	slime.velocity.x = away.x * horiz
	slime.velocity.z = away.z * horiz
	slime.velocity.y = vert

	if slime.land_sound:
		slime.land_sound.pitch_scale = randf_range(0.9, 1.2)
		slime._play_land_sound()

	is_bouncing = true


func _update_bounce(delta):
	slime.velocity.y -= slime.data.gravity * delta

	if slime.is_on_floor():
		is_bouncing = false
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
