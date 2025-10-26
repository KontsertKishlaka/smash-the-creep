extends PlayerState
class_name IdleState

func enter() -> void:
	animation_player.play("idle")

func physics_process(_delta: float) -> void:
	var input_dir = get_movement_input()

	if input_dir.length() > 0:
		if Input.is_action_pressed("sprint"):
			state_machine.change_state(state_machine.get_node("RunState"))
		else:
			state_machine.change_state(state_machine.get_node("WalkState"))

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.change_state(state_machine.get_node("JumpState"))

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("AttackState"))
