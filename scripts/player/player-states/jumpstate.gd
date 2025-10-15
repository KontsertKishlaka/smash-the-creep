extends "res://scripts/player/state.gd"

@export var jump_speed = 7

func enter():
	state_machine.player.velocity.y = jump_speed

func physics_update(delta):
	state_machine.player.velocity.y += state_machine.player.gravity * delta
	state_machine.player.move_and_slide()
	
	if state_machine.player.is_on_floor():
		state_machine.change_state("Idle")
