extends Node
class_name PlayerStateMachine

@export var player: Player
@export var initial_state: PlayerState

var current_state: PlayerState
var states: Dictionary = {}

func _ready() -> void:
	await player.ready  # Ждём инициализации игрока

	# Автоматически собираем все состояния
	for state in get_children():
		if state is PlayerState:
			states[state.name] = state
			_initialize_state(state)

	if initial_state:
		change_state(initial_state)
	else:
		printerr("Initial state not set!")

func _initialize_state(state: PlayerState):
	state.state_machine = self
	state.player = player
	state.animation_player = player.get_node("Animation")
	state.audio_component = player.get_node("AudioComponent")

func change_state(new_state: PlayerState) -> void:
	if not new_state or new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if current_state:
		current_state.process(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)
	if current_state:
		current_state.post_physics_process(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

# Вспомогательный метод для поиска состояния по имени
func get_state(state_name: String) -> PlayerState:
	return states.get(state_name)
