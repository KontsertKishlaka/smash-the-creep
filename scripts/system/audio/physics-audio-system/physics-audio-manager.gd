extends Node

var config: PhysicsAudioConfig

func _ready():
	print("🌿 PhysicsAudioManager инициализирован")

	_load_config()

	# Подключаем сигналы
	SignalBus.push_sound_played.connect(_on_push_sound_played)
	SignalBus.rigidbody_impact_sound.connect(_on_rigidbody_impact_sound)

func _load_config() -> void:
	# Пытаемся загрузить конфиг из стандартного пути
	var config_path = "res://assets/config/physics_audio_config.tres"

	if ResourceLoader.exists(config_path):
		config = load(config_path)
	else:
		config = PhysicsAudioConfig.new()

		# Сохраняем конфиг по умолчанию для будущего редактирования
		_save_default_config(config_path)

func _save_default_config(path: String) -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("res://assets/config"):
		dir.make_dir("assets/config")

	ResourceSaver.save(config, path)

func _on_push_sound_played(position: Vector3, force: float, pusher_type: String):
	if not config:
		return

	var sounds = _get_push_sounds(pusher_type)

	if sounds.is_empty():
		return

	var volume = _calculate_push_volume(force)
	var random_sound = sounds[randi() % sounds.size()]

	SignalBus.play_sound_3d.emit(random_sound, position, volume)

func _on_rigidbody_impact_sound(position: Vector3, impact_force: float, material_type: String):
	if not config:
		return

	var sounds = _get_impact_sounds(material_type)

	if sounds.is_empty():
		return

	var volume = _calculate_impact_volume(impact_force)
	var random_sound = sounds[randi() % sounds.size()]

	SignalBus.play_sound_3d.emit(random_sound, position, volume)

func _get_push_sounds(pusher_type: String) -> Array[AudioStream]:
	if not config:
		return []

	match pusher_type:
		Constants.GROUP_PLAYER: return config.player_push_sounds
		Constants.GROUP_ENEMIES: return config.enemy_push_sounds
		_: return config.default_push_sounds

func _get_impact_sounds(material_type: String) -> Array[AudioStream]:
	if not config:
		return []

	match material_type:
		"wood": return config.wood_impact_sounds
		"metal": return config.metal_impact_sounds
		"stone": return config.stone_impact_sounds
		_: return config.wood_impact_sounds

func _calculate_push_volume(force: float) -> float:
	if not config:
		return 0.0

	var normalized_force = clamp(force / config.max_push_force, 0.0, 1.0)
	return lerp(config.min_push_volume, config.max_push_volume, normalized_force)

func _calculate_impact_volume(impact_force: float) -> float:
	return _calculate_push_volume(impact_force) + 3.0
