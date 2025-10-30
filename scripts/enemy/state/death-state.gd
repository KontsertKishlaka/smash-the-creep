extends EnemyState
class_name DeathState

const ESE = preload("uid://ctowofqaibkck")

@export var fade_time: float = 1.2
var fade_timer: float = 0.0
var mesh: MeshInstance3D = null

var _death_type: int = 0
var _particles_emitted: bool = false
var _death_sound_played: bool = false
var _original_scale: Vector3

@export var death_particles_scene: PackedScene
@export var death_sound: AudioStream
@export var dissolve_speed: float = 2.0

func enter(_params: Array = []):
	mesh = _find_mesh()
	_original_scale = slime.scale
	
	_death_type = randi() % ESE.DeathType.size()
	
	slime.set_physics_process(false)
	slime.set_process(false)
	slime.set_collision_layer(0)
	slime.set_collision_mask(0)
	
	_start_death_effects()

func physics_update(delta):
	fade_timer += delta
	
	match _death_type:
		ESE.DeathType.DISSOLVE:
			_update_dissolve_death(delta)
		ESE.DeathType.EXPLODE:
			_update_explode_death(delta)
	# и т.д.
	
	if fade_timer >= fade_time:
		_finalize_death()

func _update_dissolve_death(delta: float):
	if mesh:
		var progress = fade_timer / fade_time
		
		mesh.modulate.a = clamp(1.0 - progress, 0, 1)
		
		var scale_factor = 1.0 - progress * 0.8
		slime.scale = _original_scale * scale_factor
		
		mesh.rotation.y += delta * 2.0

func _update_explode_death(_delta: float):
	if mesh:
		var progress = fade_timer / fade_time
		
		if progress < 0.3:
			var explosion_scale = 1.0 + progress * 3.0
			slime.scale = _original_scale * explosion_scale
		else:
			var collapse_progress = (progress - 0.3) / 0.7
			var collapse_scale = 4.0 - collapse_progress * 3.8
			collapse_scale = max(0.01, collapse_scale)  # Предотвращаем scale = 0
			slime.scale = _original_scale * collapse_scale
			
			mesh.modulate.a = clamp(1.0 - collapse_progress * 3.0, 0, 1)

func _update_sink_death(delta: float):
	if mesh:
		var progress = fade_timer / fade_time
		
		slime.global_position.y -= delta * 0.5
		
		var squash_factor = 1.0 - progress * 0.5
		var stretch_factor = 1.0 + progress * 0.3
		slime.scale = Vector3(
			_original_scale.x * stretch_factor,
			_original_scale.y * squash_factor,
			_original_scale.z * stretch_factor
		)
		
		mesh.modulate.a = clamp(1.0 - progress, 0, 1)

func _update_fade_death(_delta: float):
	if mesh:
		mesh.modulate.a = clamp(1.0 - (fade_timer / fade_time), 0, 1)

func _start_death_effects():
	if not _death_sound_played:
		_play_death_sound()
		_death_sound_played = true
	
	_spawn_death_particles()
	
	SignalBus.enemy_died.emit(slime)
	
	match _death_type:
		ESE.DeathType.EXPLODE:
			_start_explosion_effects()
		ESE.DeathType.DISSOLVE:
			_start_dissolve_effects()

func _play_death_sound():
	var death_sounds = [
		# preload("res://sounds/enemy_death_1.wav"),
		# preload("res://sounds/enemy_death_2.wav"),
		# preload("res://sounds/enemy_death_3.wav")
	]
	
	if death_sounds.size() == 0:
		return
	
	var random_sound = death_sounds[randi() % death_sounds.size()]
	SignalBus.play_sound_3d.emit(
		random_sound,
		slime.global_position
	)

func _spawn_death_particles():
	if not _particles_emitted and death_particles_scene:
		SignalBus.spawn_effect.emit(
			death_particles_scene,
			slime.global_position + Vector3.UP * 0.5,
			Vector3.UP
		)
		_particles_emitted = true
		
		if _death_type == ESE.DeathType.EXPLODE:
			SignalBus.spawn_effect.emit(
				#preload("res://effects/explosion_ring.tscn"),
				slime.global_position,
				Vector3.UP
			)

func _start_explosion_effects():
	SignalBus.play_sound_3d.emit(
		#preload("res://sounds/explosion.wav"),
		slime.global_position
	)

func _start_dissolve_effects():
	SignalBus.spawn_effect.emit(
		#preload("res://effects/dissolve_particles.tscn"),
		slime.global_position,
		Vector3.UP
	)

func _finalize_death():
	if _death_type == ESE.DeathType.EXPLODE:
		SignalBus.spawn_effect.emit(
			#preload("res://effects/smoke_cloud.tscn"),
			slime.global_position,
			Vector3.UP
		)
	
	slime.queue_free()

func _find_mesh() -> MeshInstance3D:
	if slime.has_node("MeshInstance3D"):
		return slime.get_node("MeshInstance3D")
	
	for child in slime.get_children():
		if child is MeshInstance3D:
			return child
	
	return null

func _exit_tree():
	if slime and is_instance_valid(slime):
		slime.queue_free()
