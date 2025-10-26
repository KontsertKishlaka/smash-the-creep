extends PlayerState

@export var speed: float = 5  # Можно убрать, если используем player_data.speed

func enter():
	pass

func physics_update(delta):
	state_machine._handle_movement(delta)  # Делегируем, speed из player_data
