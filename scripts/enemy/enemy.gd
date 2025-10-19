extends CharacterBody3D
class_name Enemy

@export var enemy_data: Resource
@export var jump_speed: float = 5.0
@export var gravity: float = 30.0

func _physics_process(delta):
	if enemy_data == null:
		return

	velocity.z = enemy_data.speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if randi() % 100 < 2:
			velocity.y = jump_speed

	move_and_slide()
