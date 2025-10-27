extends Node

# Константы для шин - используем StringName для производительности
const BUS_MASTER: StringName = &"Master"
const BUS_MUSIC: StringName = &"Music"
const BUS_SFX: StringName = &"SFX"

@export_category("Audio Settings")
@export_range(1, 32) var max_concurrent_sfx: int = 16

# Приватные переменные
var _sfx_pool: Array[AudioStreamPlayer3D] = []
var _available_sfx_indices: Array[int] = []
var _music_player: AudioStreamPlayer

func _ready() -> void:
	# Проверяем, что шины существуют
	_verify_audio_buses()

	# Инициализируем системы
	_setup_music_player()
	_setup_sfx_pool()

	# Подписываемся на сигналы
	_connect_signals()

	print("AudioManager MVP initialized")

func _verify_audio_buses() -> void:
	var buses = ["Master", "Music", "SFX"]
	for bus_name in buses:
		var bus_index = AudioServer.get_bus_index(bus_name)
		if bus_index == -1:
			push_warning("Audio bus '%s' not found! Please create it in Audio settings." % bus_name)

func _setup_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)

func _setup_sfx_pool() -> void:
	for i in max_concurrent_sfx:
		var player := AudioStreamPlayer3D.new()
		player.bus = BUS_SFX
		player.max_distance = 25.0
		player.attenuation_filter_cutoff_hz = 5000
		player.finished.connect(_on_sfx_finished.bind(i))
		add_child(player)
		_sfx_pool.append(player)
		_available_sfx_indices.append(i)

func _connect_signals() -> void:
	SignalBus.play_sound_3d.connect(_on_play_sound_3d)
	SignalBus.play_music.connect(_on_play_music)
	SignalBus.stop_music.connect(_on_stop_music)

# Обработчики сигналов
func _on_play_sound_3d(sound: AudioStream, position: Vector3, volume_db: float = 0.0, bus: StringName = BUS_SFX) -> void:
	if _available_sfx_indices.is_empty():
		return

	var index: int = _available_sfx_indices.pop_back()
	var player: AudioStreamPlayer3D = _sfx_pool[index]

	player.stream = sound
	player.global_position = position
	player.volume_db = volume_db
	player.bus = bus
	player.play()

func _on_play_music(music: AudioStream, fade_in_time: float = 1.0, volume_db: float = 0.0) -> void:
	_music_player.stream = music
	_music_player.volume_db = volume_db
	_music_player.play()

func _on_stop_music(fade_out_time: float = 1.0) -> void:
	_music_player.stop()

func _on_sfx_finished(index: int) -> void:
	if not _available_sfx_indices.has(index):
		_available_sfx_indices.append(index)

# Публичные методы для прямого доступа (опционально)
func play_sound_3d(sound: AudioStream, position: Vector3, volume_db: float = 0.0) -> void:
	_on_play_sound_3d(sound, position, volume_db)

func play_music(music: AudioStream) -> void:
	_on_play_music(music)
