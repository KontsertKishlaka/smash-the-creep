extends "res://scripts/player/state.gd"

@export var speed: float = 20

func enter():
	pass

func physics_update(delta):
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if direction == 0:
		state_machine.change_state("idle")
		return

	var velocity = state_machine.player.velocity
	velocity.x = direction * speed
	state_machine.player.velocity = velocity
	state_machine.player.move_and_slide()
		
	if Input.is_action_pressed("jump"):
		state_machine.change_state("jump")
