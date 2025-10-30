extends Node
class_name PlayerState

# Автоматически инжектятся StateMachine
var state_machine: PlayerStateMachine
var player: Player
var animation_player: AnimationPlayer
var audio_component: AudioComponent

# Виртуальные методы
func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func post_physics_process(_delta: float) -> void:
	if player.has_node(str(Constants.PUSH_COMPONENT)):
		player.get_node(str(Constants.PUSH_COMPONENT)).push_rigid_bodies()

func handle_input(_event: InputEvent) -> void:
	pass

# Вспомогательные методы
func get_movement_input() -> Vector3:
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.z = Input.get_axis("move_forwards", "move_backwards")
	return input_dir

func _apply_gravity(delta: float):
	if not player.is_on_floor():
		player.velocity.y -= Constants.DEFAULT_GRAVITY * delta
