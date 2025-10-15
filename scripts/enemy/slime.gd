extends CharacterBody3D
class_name Slime

@export var speed: float = 3.0
@export var gravity: float = 20.0
@export var detection_range: float = 10.0
@export var player: Player

var velocity_y = 2.0

func _physics_process(delta):
	if not player:
		return

	# направление на игрока
	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance < detection_range:
		# Преследуем игрока
		var dir = to_player.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		# Патрулируем (пока просто стоим)
		velocity.x = move_toward(velocity.x, 0, delta * speed)
		velocity.z = move_toward(velocity.z, 0, delta * speed)

	# Гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
