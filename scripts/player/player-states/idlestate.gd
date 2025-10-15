extends "res://scripts/player/state.gd"

func enter():
	pass

func physics_update(delta):
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if direction != 0:
		state_machine.change_state("run")
	if Input.is_action_pressed("jump"):
		state_machine.change_state("jump")
