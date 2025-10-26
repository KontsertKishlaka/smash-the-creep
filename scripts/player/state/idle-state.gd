extends State

func enter():
	if state_machine and state_machine.player:
		var velocity = state_machine.player.velocity
		velocity.x = 0
		velocity.z = 0
		state_machine.player.velocity = velocity

func physics_update(delta):
	if not state_machine or not state_machine.player:
		return
	state_machine._handle_movement(delta)  # Полностью делегируем
