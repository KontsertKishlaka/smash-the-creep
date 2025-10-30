extends PlayerMoveState
class_name WalkState

func enter() -> void:
	_movement_speed = player.player_data.walk_speed
	animation_player.play(str(Constants.ANIM_IDLE))
	#animation_player.play(str(Constants.ANIM_WALK))
	super()

func _should_transition_to_other_state() -> bool:
	if super():
		return true

	if Input.is_action_pressed("sprint") and _has_stamina():
		state_machine.change_state(state_machine.get_state(str(Constants.STATE_RUN)))
		return true

	return false

# TODO: Реализовать систему стамины
func _has_stamina() -> bool:
	return true
