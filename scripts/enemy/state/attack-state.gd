extends EnemyState
class_name EnemyAttackState

@export var state_enum: int = EnemyStatesEnum.State.AttackState

var prep_timer: float = 0.0
var prep_duration: float = 0.2
var attacking_air: bool = false
var is_bouncing: bool = false
var post_attack_delay_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var target: Node3D = null
var original_scale: Vector3
var attack_target_position: Vector3

var flip_active: bool = false
var flip_remaining: float = 0.0
var rot_axis: Vector3 = Vector3(1,0,0)

enum AttackMode { ROTATE_ONLY, ROTATE_FLIP, FLIP_ONLY }
var current_attack: int = AttackMode.FLIP_ONLY

@export var attack_jump_power: float = 2.5
@export var attack_knockback_multiplier: float = 1.5
@export var squash_factor: float = 0.7
@export var stretch_factor: float = 1.5
@export var air_stretch_factor: float = 1.3
@export var bounce_squash_factor: float = 0.85

func enter(_params: Array = []):  # ДОБАВЛЯЕМ ПАРАМЕТР
	if slime.player and is_instance_valid(slime.player):
		target = slime.player
	else:
		target = null

	original_scale = slime.scale
	prep_timer = prep_duration
	attacking_air = false
	is_bouncing = false
	post_attack_delay_timer = 0.0
	attack_cooldown_timer = 0.0
	flip_active = false
	flip_remaining = 0.0

	current_attack = randi() % 3

	original_scale = slime.scale
	prep_timer = prep_duration
	attacking_air = false
	is_bouncing = false
	post_attack_delay_timer = 0.0
	attack_cooldown_timer = 0.0
	flip_active = false
	flip_remaining = 0.0

	current_attack = randi() % 3

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
	var horizontal_dir = to_target
	horizontal_dir.y = 0
	horizontal_dir = horizontal_dir.normalized()

	if prep_timer > 0.0:
		prep_timer -= delta
		slime.velocity = Vector3.ZERO

		var t = 1.0 - (prep_timer / prep_duration)
		var prep_scale = Vector3(
			original_scale.x * lerp(1.0, stretch_factor, t),
			original_scale.y * lerp(1.0, squash_factor, t),
			original_scale.z * lerp(1.0, stretch_factor, t)
		)
		slime.scale = prep_scale
		slime.look_at(target.global_position, Vector3.UP)

		if prep_timer <= 0.0:
			attack_target_position = Vector3(target.global_position.x, slime.global_position.y, target.global_position.z)
			_request_attack_jump()
			attacking_air = true
		return

	if attacking_air:
		slime.velocity.x = horizontal_dir.x * slime.data.speed * 2.5
		slime.velocity.z = horizontal_dir.z * slime.data.speed * 2.5
		slime.velocity.y -= slime.data.gravity * delta

		var air_scale = Vector3(original_scale.x*0.9, original_scale.y*air_stretch_factor, original_scale.z*0.9)
		slime.scale = slime.scale.lerp(air_scale, 0.15)

		# наклон лбом к игроку
		var look_dir = (attack_target_position - slime.global_position).normalized()
		look_dir.y = 0
		slime.rotation.x = lerp(slime.rotation.x, -0.3, 0.1)
		slime.rotation.y = lerp(slime.rotation.y, atan2(look_dir.x, look_dir.z), 0.1)
		slime.rotation.z = 0

		if (slime.global_position - attack_target_position).length() <= slime.data.attack_range:
			_perform_attack()
			post_attack_delay_timer = 0.05
			attacking_air = false
			_start_bounce()
		return

	if post_attack_delay_timer > 0.0:
		post_attack_delay_timer -= delta
		slime.velocity.y -= slime.data.gravity * delta
		return

func _request_attack_jump():
	if not target or not is_instance_valid(target):
		return

	var dir = attack_target_position - slime.global_position
	dir.y = 0
	dir = dir.normalized()

	slime.velocity.x = dir.x * slime.data.speed * 2.5
	slime.velocity.z = dir.z * slime.data.speed * 2.5
	slime.velocity.y = slime.data.attack_jump_velocity * attack_jump_power

	# выбор типа атаки
	match current_attack:
		AttackMode.ROTATE_ONLY:
			flip_active = true
			flip_remaining = TAU
			rot_axis = Vector3(0, randf_range(-1.0,1.0), 0).normalized()
		AttackMode.ROTATE_FLIP:
			flip_active = true
			flip_remaining = TAU
			rot_axis = Vector3(1, randf_range(-0.3,0.3), 0).normalized()
		AttackMode.FLIP_ONLY:
			flip_active = true
			flip_remaining = TAU
			rot_axis = Vector3(1,0,0)

func _perform_attack():
	if not target or not is_instance_valid(target):
		return

	if target.has_method("take_damage"):
		target.take_damage(slime.data.attack_damage, slime)

	attack_cooldown_timer = slime.data.attack_cooldown

func _start_bounce():
	if not target or not is_instance_valid(target):
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		return

	var away = slime.global_position - target.global_position
	away.y = 0
	away = away.normalized()

	var horiz = slime.data.attack_jump_velocity * slime.data.attack_knockback_horizontal * attack_knockback_multiplier
	var vert  = slime.data.attack_jump_velocity * slime.data.attack_knockback_vertical * attack_knockback_multiplier

	slime.velocity.x = away.x * horiz
	slime.velocity.z = away.z * horiz
	slime.velocity.y = vert

	slime.scale = Vector3(original_scale.x*1.2, original_scale.y*bounce_squash_factor, original_scale.z*1.2)

	match current_attack:
		AttackMode.ROTATE_ONLY:
			flip_active = true
			flip_remaining = TAU
			rot_axis = Vector3(0, randf_range(-1.0,1.0), 0).normalized()
		AttackMode.ROTATE_FLIP:
			flip_active = true
			flip_remaining = TAU
			rot_axis = Vector3(1, randf_range(-0.3,0.3), 0).normalized()
		AttackMode.FLIP_ONLY:
			flip_active = true
			flip_remaining = TAU
			rot_axis = Vector3(1,0,0)

	if slime.land_sound:
		slime.land_sound.pitch_scale = randf_range(0.9, 1.2)
		slime._play_land_sound()

	is_bouncing = true

func _update_bounce(delta):
	slime.velocity.y -= slime.data.gravity * delta

	slime.scale = slime.scale.lerp(original_scale, 0.15)

	if flip_active:
		var flight_time = max(slime.velocity.y / slime.data.gravity * 2.0, 0.2)
		var rot_step = (TAU / flight_time) * delta
		if rot_step > flip_remaining:
			rot_step = flip_remaining
		var ease_factor = sin((1.0 - flip_remaining/TAU) * PI)
		slime.rotate(rot_axis, rot_step * ease_factor * 1.5)
		flip_remaining -= rot_step
		if flip_remaining <= 0.0:
			flip_active = false
			slime.rotation = Vector3.ZERO

	if slime.is_on_floor():
		is_bouncing = false
		flip_active = false
		slime.scale = original_scale
		slime.rotation = Vector3.ZERO
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
