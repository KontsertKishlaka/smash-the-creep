extends CharacterBody3D
class_name Slime

@export var data: EnemyData
@export var player: Player

@export var test_damage_interval: float = 1.0
@export var test_damage_amount: int = 1

@onready var state_machine: EnemyStateMachine = $StateMachine
@onready var land_sound: AudioStreamPlayer3D = $LandSound
@onready var jump_sound: AudioStreamPlayer3D = $JumpSound

var health_system: HealthSystem

@export var jump_stretch_factor: float = 1.3
@export var land_squash_factor: float = 0.8
@export var squash_lerp_speed: float = 0.15
@export var stretch_lerp_speed: float = 0.15

var land_animation_timer: float = 0.0
var land_animation_duration: float = 0.3

var jump_timer: float = 0.0
var patrol_target: Vector3
var was_on_floor: bool = true
var test_damage_timer: float = 0.0
var is_dead: bool = false

var original_scale: Vector3
var jumping: bool = false
var just_landed: bool = false

func _set_new_patrol_target():
	var random_offset = Vector3(
		randf_range(-data.patrol_radius, data.patrol_radius),
		0,
		randf_range(-data.patrol_radius, data.patrol_radius)
	)
	patrol_target = global_position + random_offset

func _ready():
	randomize()
	if not data:
		printerr("Slime: EnemyData не назначен!")
		return

	health_system = HealthSystem.new(self, name, data.max_health)
	
	_set_new_patrol_target()
	original_scale = scale

	_connect_health_signals()

func _connect_health_signals():
	SignalBus.enemy_damaged.connect(_on_enemy_damaged)

func _on_enemy_damaged(enemy: Node, _damage: int, source: Node):
	if enemy == self and is_alive() and not is_invincible():
		state_machine.change_state(EnemyStatesEnum.State.TakeDamageState, [source])

func _process(delta: float):
	if not data or is_dead:
		return
	
	health_system.update(delta)
	
	test_damage_timer += delta
	if test_damage_timer >= test_damage_interval:
		test_damage_timer = 0.0
		take_damage(test_damage_amount, self)

func _physics_process(delta):
	if not data or not player or is_dead:
		return

	var was_on_floor_before = is_on_floor()

	if not is_on_floor():
		velocity.y -= data.gravity * delta
		if not jumping:
			jumping = true
	else:
		if jumping:
			just_landed = true
			land_animation_timer = land_animation_duration
		jumping = false
		velocity.y = max(velocity.y, 0)

	var horiz_speed = Vector2(velocity.x, velocity.z).length()
	var max_allowed = max(data.speed * 6.0, data.speed)
	if horiz_speed > max_allowed:
		var factor = max_allowed / horiz_speed
		velocity.x *= factor
		velocity.z *= factor

	move_and_slide()

	var just_landed_event = not was_on_floor_before and is_on_floor()
	if just_landed_event:
		_play_land_sound()
	var just_jumped_event = was_on_floor_before and not is_on_floor() and velocity.y > 0.1
	if just_jumped_event:
		_play_jump_sound()

	was_on_floor = is_on_floor()

	if jumping:
		var target_scale = Vector3(
			original_scale.x * 0.9,
			original_scale.y * jump_stretch_factor,
			original_scale.z * 0.9
		)
		scale = scale.lerp(target_scale, stretch_lerp_speed)
	elif land_animation_timer > 0:
		land_animation_timer -= delta
		
		var progress = 1.0 - (land_animation_timer / land_animation_duration)
		
		if progress < 0.5:
			var squash_progress = progress * 2.0
			var target_scale = Vector3(
				original_scale.x * (1.0 + squash_progress * 0.2),
				original_scale.y * (1.0 - squash_progress * 0.2),
				original_scale.z * (1.0 + squash_progress * 0.2)
			)
			scale = target_scale
		else:
			var restore_progress = (progress - 0.5) * 2.0
			scale = scale.lerp(original_scale, restore_progress)
		
		if land_animation_timer <= 0:
			scale = original_scale
			just_landed = false
	else:
		scale = scale.lerp(original_scale, squash_lerp_speed)
		
		if (scale - original_scale).length() < 0.005:
			scale = original_scale

func _rotate_toward(direction: Vector3, delta: float):
	if direction.length() > 0.01:
		var target_angle = atan2(direction.x, direction.z)
		var desired = target_angle + data.model_yaw_offset
		rotation.y = lerp_angle(rotation.y, desired, delta * data.rotation_smoothness)

func take_damage(amount: int, source: Node = null):
	if is_dead:
		return

	health_system.take_damage(amount, source)

func _on_death(_killer: Node = null):
	if is_dead:
		return
	
	is_dead = true
	state_machine.change_state(EnemyStatesEnum.State.DeathState)
	collision_layer = 0
	collision_mask = 1
	
	_die_animation()

func _die_animation():
	is_dead = true
	state_machine.change_state(EnemyStatesEnum.State.DeathState)
	collision_layer = 0
	collision_mask = 1

	var choice = randi() % 3
	match choice:
		0:
			await _die_compress_and_fade()
		1:
			await _die_splat_fall()
		2:
			await _die_bubble_up()

	queue_free()

func _die_compress_and_fade():
	var duration = 1.0
	var timer = 0.0
	var start_scale = scale
	var start_rotation_y = rotation.y
	while timer < duration:
		var delta = get_process_delta_time()
		timer += delta
		var t = timer / duration

		scale = start_scale * (1.0 - t)
		rotation.y = start_rotation_y + sin(t * PI * 3) * deg_to_rad(15)
		await get_tree().process_frame

func _die_splat_fall():
	var fall_velocity = Vector3.ZERO
	var gravity = data.gravity
	var start_scale = scale
	var landed = false
	while not landed:
		var delta = get_process_delta_time()
		fall_velocity.y -= gravity * delta

		velocity = fall_velocity
		move_and_slide()
		fall_velocity = velocity

		if is_on_floor():
			landed = true
			var t = 0.0
			var duration = 0.5
			while t < duration:
				var dt = get_process_delta_time()
				t += dt
				var f = t / duration
				scale.x = start_scale.x * (1.0 + f * 1.5)
				scale.z = start_scale.z * (1.0 + f * 1.5)
				scale.y = start_scale.y * (1.0 - f * 0.8)
				await get_tree().process_frame

			await get_tree().create_timer(0.5).timeout

func _die_bubble_up():
	var start_pos = global_position
	var start_scale = scale
	var duration = 1.0
	var timer = 0.0

	while timer < duration:
		var delta = get_process_delta_time()
		timer += delta
		var t = timer / duration

		global_position.y = start_pos.y + sin(t * PI) * 1.5
		scale = start_scale * (1.0 + t * 2.0)
		await get_tree().process_frame

func _play_land_sound():
	if land_sound and not land_sound.playing:
		land_sound.pitch_scale = randf_range(0.9, 1.1)
		land_sound.play()

func _play_jump_sound():
	if jump_sound and not jump_sound.playing:
		jump_sound.pitch_scale = randf_range(0.9, 1.1)
		jump_sound.play()

func get_current_health() -> int:
	return health_system.get_current_health()

func get_max_health() -> int:
	return health_system.get_max_health()

func is_alive() -> bool:
	return health_system.is_alive()

func is_invincible() -> bool:
	return health_system.is_invincible()
