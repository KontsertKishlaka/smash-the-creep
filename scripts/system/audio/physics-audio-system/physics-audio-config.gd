extends Resource
class_name PhysicsAudioConfig

@export_category("Push Sounds")
@export var player_push_sounds: Array[AudioStream]
@export var enemy_push_sounds: Array[AudioStream]
@export var default_push_sounds: Array[AudioStream]

@export_category("Impact Sounds")
@export var wood_impact_sounds: Array[AudioStream]
@export var metal_impact_sounds: Array[AudioStream]
@export var stone_impact_sounds: Array[AudioStream]

@export_category("Volume Settings")
@export_range(-24.0, 6.0) var min_push_volume: float = -12.0
@export_range(-24.0, 6.0) var max_push_volume: float = -4.0
@export var max_push_force: float = 10.0
