extends Node
class_name EnemyStateMachine

const ESE = preload("uid://ctowofqaibkck")

@export var initial_state: int = ESE.State.PatrolState

var current_state: EnemyState
var states: Dictionary = {}

func _ready():
	var slime = get_parent() as Slime

	for child in get_children():
		if child is EnemyState:
			child.state_machine = self
			child.slime = slime
			states[child.name] = child

	change_state(initial_state)

func change_state(new_state_enum: int, params: Array = []):
	if current_state:
		current_state.exit()

	var state_name = ESE.get_state_name(new_state_enum)
	if states.has(state_name):
		current_state = states[state_name]
		
		# Передача параметров в состояние
		if params.size() > 0:
			current_state.enter(params)
		else:
			current_state.enter()
	else:
		printerr("State not found: ", state_name)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func _process(delta):
	if current_state:
		current_state.update(delta)
