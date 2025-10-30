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
var _is_music_enabled: bool = true
var _current_music: AudioStream
var _music_volume: float = -6.0  # Комфортная громкость музыки по умолчанию

func _ready() -> void:
	_verify_audio_buses()  # Проверяем, что шины существуют

	_setup_music_player()  # Инициализируем систему музыки
	_setup_sfx_pool()	   # Инициализируем sfx-пулл

	_connect_signals()	   # Подписываемся на сигналы

	print("🌿 AudioManager инициализирован")

# Публичные методы для прямого доступа (опционально)
func play_sound_3d(sound: AudioStream, position: Vector3, volume_db: float = 0.0) -> void:
	_on_play_sound_3d(sound, position, volume_db)

func play_music(music: AudioStream) -> void:
	_on_play_music(music)

# Публичные методы для управления музыкой
func set_music_enabled(enabled: bool) -> void:
	_is_music_enabled = enabled
	if not enabled and _music_player.playing:
		_music_player.stop()
	elif enabled and _current_music and not _music_player.playing:
		play_music(_current_music)

func is_music_enabled() -> bool:
	return _is_music_enabled

func set_music_volume(volume_db: float) -> void:
	_music_volume = volume_db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MUSIC), volume_db)

func get_music_volume() -> float:
	return _music_volume

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
	# Звуки
	SignalBus.play_sound_3d.connect(_on_play_sound_3d)
	SignalBus.play_music.connect(_on_play_music)
	SignalBus.stop_music.connect(_on_stop_music)
	# Музыка
	SignalBus.toggle_music.connect(_on_toggle_music)
	SignalBus.set_music_volume.connect(_on_set_music_volume)
	SignalBus.scene_music_changed.connect(_on_scene_music_changed)

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

func _on_sfx_finished(index: int) -> void:
	if not _available_sfx_indices.has(index):
		_available_sfx_indices.append(index)

# Обработчик play_music
func _on_play_music(music: AudioStream, fade_in_time: float = 1.0, volume_db: float = -6.0) -> void:
	if not _is_music_enabled:
		return

	_current_music = music

	# Если уже играет эта музыка - ничего не делаем
	if _music_player.stream == music and _music_player.playing:
		return

	_music_player.stream = music
	_music_player.volume_db = volume_db

	# Простой fade-in
	if fade_in_time > 0:
		_music_player.volume_db = -80.0
		_music_player.play()
		var tween = create_tween()
		tween.tween_property(_music_player, "volume_db", volume_db, fade_in_time)
	else:
		_music_player.play()

# Обработчик stop_music
func _on_stop_music(fade_out_time: float = 1.0) -> void:
	if fade_out_time > 0 and _music_player.playing:
		var tween = create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_out_time)
		tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()

func _on_toggle_music(enabled: bool) -> void:
	set_music_enabled(enabled)

func _on_set_music_volume(volume_db: float) -> void:
	set_music_volume(volume_db)

func _on_scene_music_changed(_scene_name: String, music: AudioStream) -> void:
	_on_play_music(music, 2.0)  # Плавный переход 2 секунды
