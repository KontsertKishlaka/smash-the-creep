extends State

@export var speed: float = 10  # Можно убрать, multiplier в _handle_movement

func enter():
	pass

func physics_update(delta):
	state_machine._handle_movement(delta)  # Делегируем
