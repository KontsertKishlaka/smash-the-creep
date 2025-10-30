extends Node3D
class_name AudioComponent

@export_category("Entity Sounds")
@export var footstep_sounds: Array[AudioStream]
@export var attack_sounds: Array[AudioStream]
@export var jump_sound: AudioStream
@export var land_sound: AudioStream

@export_category("Volume Settings")
@export_range(-24.0, 6.0) var footstep_volume_db: float = -8.
@export_range(-24.0, 6.0) var attack_volume_db: float = -8.
@export_range(-24.0, 6.0) var movement_volume_db: float = -8.

@export_category("Push Sounds")
@export var push_sounds: Array[AudioStream]
@export_range(-24.0, 6.0) var push_volume_db: float = -10.

# Публичный API
func play_sound(sound: AudioStream, volume_db: float = 0.) -> void:
	if sound:
		SignalBus.play_sound_3d.emit(sound, global_position, volume_db)

func play_random_sound(sounds: Array[AudioStream], volume_db: float = 0.) -> void:
	if sounds.is_empty():
		return
	var random_sound = sounds[randi() % sounds.size()]
	play_sound(random_sound, volume_db)

# Специфичные методы
func play_attack() -> void:
	play_random_sound(attack_sounds, attack_volume_db)

func play_jump() -> void:
	play_sound(jump_sound, movement_volume_db)

func play_land() -> void:
	play_sound(land_sound, movement_volume_db)

func play_footstep() -> void:
	play_random_sound(footstep_sounds, footstep_volume_db)

func play_push() -> void:
	play_random_sound(push_sounds, push_volume_db)
