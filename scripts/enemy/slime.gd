extends CharacterBody3D
class_name Slime

@export var data: EnemyData
@export var player: Player

@export var test_damage_interval: float = 1.0
@export var test_damage_amount: int = 1

@onready var state_machine: EnemyStateMachine = $StateMachine
@onready var land_sound: AudioStreamPlayer3D = $LandSound
@onready var jump_sound: AudioStreamPlayer3D = $JumpSound

var jump_timer: float = 0.0
var patrol_target: Vector3
var was_on_floor: bool = true

var test_damage_timer: float = 0.0
var is_dead: bool = false

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

	_set_new_patrol_target()

func _physics_process(delta):
	if not data or not player:  # Проверка на null
		return
	if not data:
		return

	test_damage_timer += delta
	if test_damage_timer >= test_damage_interval:
		test_damage_timer = 0.0
		take_damage(test_damage_amount, self)

	var was_on_floor_before = is_on_floor()

	if not is_on_floor():
		velocity.y -= data.gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0.0

	var horiz_speed = Vector2(velocity.x, velocity.z).length()
	var max_allowed = max(data.speed * 6.0, data.speed)
	if horiz_speed > max_allowed:
		var factor = max_allowed / horiz_speed
		velocity.x *= factor
		velocity.z *= factor

	move_and_slide()

	var just_landed = not was_on_floor_before and is_on_floor()
	if just_landed:
		_play_land_sound()
	var just_jumped = was_on_floor_before and not is_on_floor() and velocity.y > 0.1
	if just_jumped:
		_play_jump_sound()

	was_on_floor = is_on_floor()

func _rotate_toward(direction: Vector3, delta: float):
	if direction.length() > 0.01:
		var target_angle = atan2(direction.x, direction.z)
		var desired = target_angle + data.model_yaw_offset
		rotation.y = lerp_angle(rotation.y, desired, delta * data.rotation_smoothness)

func take_damage(amount: int, source: Node = null):
	if is_dead:
		return

	var source_name: String = "неизвестно"
	if source and source is Node:
		source_name = source.name

	print("%s получил %d урона от %s" % [name, amount, source_name])

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

# 1. Сжался и такой типа "неееееееееет("
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

# 2. Растекашка c:
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

# 3. Лопающийся пузырек :p
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
