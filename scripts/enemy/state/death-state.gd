extends EnemyState
class_name DeathState

@export var fade_time: float = 1.2
var fade_timer: float = 0.0
var mesh: MeshInstance3D = null

func enter():
	print("Slime в состоянии DeathState")

	slime.set_physics_process(false)
	slime.set_collision_layer(0)
	slime.set_collision_mask(0)

func physics_update(delta):
	fade_timer += delta

	if mesh:
		mesh.modulate.a = clamp(1.0 - (fade_timer / fade_time), 0, 1)

	if fade_timer >= fade_time:
		slime.queue_free()
