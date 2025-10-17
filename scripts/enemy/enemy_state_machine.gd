extends Node
class_name StateMachine

@export var initial_state: NodePath

var current_state: EnemyState

func _ready():
	# Автоматически находим Slime
	var slime = get_parent() as Slime

	# Инициализация всех дочерних состояний
	for child in get_children():
		if child is EnemyState:
			child.state_machine = self
			child.slime = slime

	# Запуск начального состояния
	if initial_state:
		change_state(initial_state)

func change_state(new_state_path: NodePath):
	if current_state:
		current_state.exit()

	var new_state = get_node_or_null(new_state_path)
	if new_state:
		current_state = new_state
		current_state.enter()
	else:
		printerr("State not found: ", new_state_path)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func _process(delta):
	if current_state:
		current_state.update(delta)
