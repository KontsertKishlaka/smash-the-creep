extends EnemyState
class_name DeathState

@export var state_enum: int = EnemyStatesEnum.State.DeathState

func enter():
	print("Slime умер!")
	# Здесь можно проиграть анимацию смерти :p
	queue_free()
