extends Node
class_name AudioComponent

@export_category("Audio Players")
@export var footsteps_audio: AudioStreamPlayer3D
@export var jump_audio: AudioStreamPlayer3D
@export var attack_audio: AudioStreamPlayer3D
@export var land_audio: AudioStreamPlayer3D
@export var voice_audio: AudioStreamPlayer3D

@export_category("Audio Libraries")
@export var footstep_sounds: Array[AudioStream]
@export var jump_sounds: Array[AudioStream]
@export var attack_sounds: Array[AudioStream]
@export var land_sounds: Array[AudioStream]
@export var pain_sounds: Array[AudioStream]

var footstep_timer: float = 0.0
var is_moving: bool = false

func _ready():
	# Настраиваем громкость из конфига
	if owner and owner.has_method("get_player_config"):
		var config: PlayerConfig = owner.get_player_config()
		set_volume_db(config.volume_db)

func _process(delta):
	_handle_footsteps(delta)

func set_volume_db(volume: float):
	for audio_player in [footsteps_audio, jump_audio, land_audio, attack_audio, voice_audio]:
		if audio_player:
			audio_player.volume_db = volume

func play_footstep():
	if footstep_sounds.size() > 0 and footsteps_audio:
		footsteps_audio.stream = footstep_sounds[randi() % footstep_sounds.size()]
		footsteps_audio.pitch_scale = randf_range(0.9, 1.1)
		footsteps_audio.play()

func play_jump():
	if jump_sounds.size() > 0 and jump_audio:
		jump_audio.stream = jump_sounds[randi() % jump_sounds.size()]
		jump_audio.play()

func play_land():
	if land_sounds.size() > 0 and land_audio:
		land_audio.stream = land_sounds[randi() % land_sounds.size()]
		land_audio.play()

func play_attack():
	if attack_sounds.size() > 0 and attack_audio:
		attack_audio.stream = attack_sounds[randi() % attack_sounds.size()]
		attack_audio.play()

func play_pain():
	if pain_sounds.size() > 0 and voice_audio:
		voice_audio.stream = pain_sounds[randi() % pain_sounds.size()]
		voice_audio.play()

func start_moving():
	is_moving = true

func stop_moving():
	is_moving = false
	footstep_timer = 0.0

func _handle_footsteps(delta: float):
	if not is_moving or not owner or not owner.has_method("get_player_config"):
		return

	var config: PlayerConfig = owner.get_player_config()
	footstep_timer += delta

	if footstep_timer >= config.footstep_interval:
		play_footstep()
		footstep_timer = 0.0
