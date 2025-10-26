extends PlayerState
class_name PlayerAttackState  # Переименован

func enter():
	print("Entered attack")
	if damage_dealer:  # Ошибка здесь (строка 6)
		damage_dealer.activate()
	else:
		printerr("Ошибка: DamageDealer не передан в PlayerAttackState!")

func exit():
	if damage_dealer:  # И здесь
		damage_dealer.deactivate()

func physics_update(delta):
	var is_jump = state_machine.current_state == state_machine.states["jump"]
	state_machine._handle_movement(delta, is_jump, 0.98, 10, 5.0 if is_jump else 0.0)
	if not Input.is_action_pressed("attack"):
		if state_machine.player.velocity.length() > 0:
			state_machine.change_state("walk" if not Input.is_action_pressed("sprint") else "run")
		else:
			state_machine.change_state("idle")
