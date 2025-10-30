extends Resource
class_name EnemyData

# --- Здоровье и защита ---
@export_category("Health & Defense")
@export_range(1, 1000, 1) var max_health: int = 5
@export_range(0.0, 5.0, 0.1) var invincibility_duration: float = 0.5

# --- Настройки движения ---
@export_category("Movement Settings")
@export var speed: float = 1.0
@export var jump_velocity: float = 5.5
@export var gravity: float = 9.8
@export var rotation_smoothness: float = 4.0
@export var model_yaw_offset: float = 0.0
@export var patrol_jump_min: float = 0.6
@export var patrol_jump_max: float = 1.0

# --- Настройки AI ---
@export_category("AI Settings")
@export var detection_range: float = 10.0
@export var jump_distance: float = 10.0
@export var jump_cooldown: float = 1.5
@export var patrol_radius: float = 6.0
@export var patrol_jump_chance: float = 0.03

# --- Атака ---
@export_category("Attack Settings")
@export var attack_range: float = 2.0
@export var attack_damage: int = 5
@export var attack_jump_velocity: float = 5.0
@export var attack_cooldown: float = 2.0 
@export var attack_knockback_horizontal: float = 1.0
@export var attack_knockback_vertical: float = 1.0

# --- Прыжковня(атаковая) ---
@export var attack_bounce_power: float = 1.15
@export var attack_bounce_variation: float = 0.12

# --- Контактный урон ---
@export_category("Damage Settings")
@export var contact_damage: int = 10
@export var contact_damage_cooldown: float = 1.0
