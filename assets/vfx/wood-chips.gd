extends Node3D
class_name WoodChips

@onready var particles: GPUParticles3D = $Particles

func _ready():
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
