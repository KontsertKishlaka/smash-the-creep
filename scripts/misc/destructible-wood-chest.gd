extends Node3D
class_name DestructibleWoodChest

@export var health: int = 2
@export var break_effect: PackedScene
@export var break_sound: AudioStream
@export var destroy_on_break: bool = true

signal destroyed(node: Node)

func take_hit(damage: int = 1):
	health -= damage
	if health <= 0:
		_on_break()

func _on_break():
	emit_signal("destroyed", self)
	
	if break_effect:
		var fx = break_effect.instantiate()
		fx.global_transform = global_transform
		get_tree().current_scene.add_child(fx)

	if break_sound:
		var audio = AudioStreamPlayer3D.new()
		audio.stream = break_sound
		#audio.global_transform.origin = global_transform.origin
		get_tree().current_scene.add_child(audio)
		audio.play()

	if destroy_on_break:
		queue_free()
