extends Node

@export var player: Player
@export var initial_state: String = "Idle"

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	states["idle"] = preload("res://scripts/player/player-states/idlestate.gd").new()
	states["run"] = preload("res://scripts/player/player-states/runstate.gd").new()
	states["jump"] = preload("res://scripts/player/player-states/jumpstate.gd").new()
	states["attack"] = preload("res://scripts/player/player-states/attackstate.gd").new()
	
	for state in states.values():
		state.state_machine = self
	
	change_state(initial_state)

func change_state(new_state_name: String):
	if current_state != null:
		current_state.exit()
	current_state = states[new_state_name]
	current_state.enter()

func _physics_process(delta):
	if current_state != null:
		current_state.physics_update(delta)

func _process(delta):
	if current_state != null:
		current_state.update(delta)
