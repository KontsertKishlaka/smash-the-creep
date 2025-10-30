extends PlayerMoveState
class_name RunState

func enter() -> void:
	_movement_speed = player.player_data.run_speed
	animation_player.play(str(Constants.ANIM_IDLE))
	#animation_player.play(str(Constants.ANIM_RUN))
	super()

func _should_transition_to_other_state() -> bool:
	if super():
		return true

	if not Input.is_action_pressed("sprint") or not _has_stamina():
		state_machine.change_state(state_machine.get_state("WalkState"))
		return true

	return false

func _get_movement_acceleration() -> float:
	return 15.0

func _get_footstep_interval() -> float:
	return .3

# TODO: Реализовать систему стамины
func _has_stamina() -> bool:
	return true
