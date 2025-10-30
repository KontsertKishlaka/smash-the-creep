extends Resource
class_name PhysicsMaterialResource

@export_category("Material Properties")
@export var material_name: String = "wood"
@export_range(.0, 1.0, .05) var friction: float = .4
@export_range(.0, 1.0, .05) var bounciness: float = .2
@export_range(.1, 5.0, .1) var density_multiplier: float = 1.0

@export_category("Sound Settings")
@export var impact_sounds: Array[AudioStream]
@export var slide_sounds: Array[AudioStream]
@export_range(-24.0, 6.0) var base_impact_volume: float = -12.0

@export_category("Visual Effects")
@export var hit_effect: PackedScene
@export var hit_particle_color: Color = Color.WHITE

# Метод для удобного получения массы
func get_mass(base_mass: float) -> float:
	return base_mass * density_multiplier
