extends PlayerState
class_name IdleState

#@onready var animation: AnimationPlayer = $"../Animation"

func enter():
	if state_machine and state_machine.player:
		var velocity = state_machine.player.velocity
		velocity.x = 0
		velocity.z = 0
		state_machine.player.velocity = velocity
