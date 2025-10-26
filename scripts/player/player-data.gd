extends Resource
class_name PlayerData

@export_category("Movement Parameters")
@export_range(1.0, 20.0, 0.5) var walk_speed: float = 5.0
@export_range(1.0, 30.0, 0.5) var run_speed: float = 10.0
@export_range(5.0, 15.0, 0.5) var jump_velocity: float = 7.0
@export_range(0.1, 1.0, 0.05) var air_control: float = 0.5
@export_range(0.8, 1.0, 0.01) var air_drag: float = 0.95

@export_category("Combat Parameters")
@export_range(1, 100, 1) var base_attsdaack_damage: int = 10
@export_range(0.1, 3.0, 0.1) var attack_cooldown: float = 0.5

@export_category("Stamina Parameters")
@export_range(1.0, 200.0, 5.0) var max_stamina: float = 100.0
@export_range(1.0, 50.0, 1.0) var stamina_drain_per_second: float = 20.0
@export_range(1.0, 50.0, 1.0) var stamina_regen_per_second: float = 15.0
