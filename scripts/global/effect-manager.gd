extends Node
class_name EffectManager

@onready var world: Node = get_tree().current_scene

func _ready():
	# Подписываемся на сигналы эффектов
	SignalBus.spawn_effect.connect(_on_spawn_effect)
	SignalBus.play_sound.connect(_on_play_sound)

func _on_spawn_effect(effect_scene: PackedScene, position: Vector3, rotation: Vector3):
	var effect = effect_scene.instantiate()
	world.add_child(effect)
	effect.global_position = position
	effect.rotation = rotation

func _on_play_sound(sound: AudioStream, position: Vector3):
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = sound
	world.add_child(audio_player)
	audio_player.global_position = position
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)
