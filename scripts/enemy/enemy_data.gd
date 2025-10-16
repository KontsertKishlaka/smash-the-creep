extends Resource
class_name EnemyData

# --- Настройки движения ---
@export var speed: float = 1.0
@export var jump_velocity: float = 5.0
@export var gravity: float = 9.8
@export var rotation_smoothness: float = 4.0
@export var model_yaw_offset: float = 0.0

# --- Настройки AI ---
@export var detection_range: float = 10.0
@export var jump_distance: float = 10.0
@export var jump_cooldown: float = 1.5
@export var patrol_radius: float = 6.0
@export var patrol_jump_chance: float = 0.03
