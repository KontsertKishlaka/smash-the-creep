extends Node
class_name MusicController

@export var scene_music: AudioStream
@export var auto_play: bool = true
@export var stop_on_exit: bool = false

func _ready() -> void:
	if auto_play and scene_music:
		SignalBus.scene_music_changed.emit(get_tree().current_scene.name, scene_music)

func _exit_tree() -> void:
	if stop_on_exit:
		SignalBus.stop_music.emit(1.0)  # Плавное затухание 1 секунда
