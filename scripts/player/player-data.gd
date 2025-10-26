extends Resource
class_name PlayerData

@export_category("Movement Parameters")
@export_range(1.0, 20.0, .5) var walk_speed: float = 5.0
@export_range(1.0, 30.0, .5) var run_speed: float = 8.0
@export_range(5.0, 15.0, .5) var jump_velocity: float = 12.0
@export_range(.1, 1.0, .05) var air_control: float = .5
@export_range(.8, 1.0, .01) var air_drag: float = .95

@export_category("Combat Parameters")
@export_range(1, 100, 1) var base_attack_damage: int = 1
@export_range(.1, 3.0, .1) var attack_cooldown: float = .5

@export_category("Stamina Parameters")
@export_range(1.0, 200.0, 5.0) var max_stamina: float = 100.0
@export_range(1.0, 50.0, 1.0) var stamina_drain_per_second: float = 20.0
@export_range(1.0, 50.0, 1.0) var stamina_regen_per_second: float = 15.0
