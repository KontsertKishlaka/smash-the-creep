extends CharacterBody3D
class_name Enemy

@export var enemy_data: Resource  # сюда назначен SlimeData
@export var jump_speed: float = 5.0  # сила прыжка
@export var gravity: float = 30.0

func _physics_process(delta):
	if enemy_data == null:
		return

	# --- простое движение вперёд по Z ---
	velocity.z = enemy_data.speed

	# --- гравитация ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# прыжок случайный для теста
		if randi() % 100 < 2:  # 2% шанс прыгнуть каждый кадр
			velocity.y = jump_speed

	# --- перемещаем врага ---
	move_and_slide()
