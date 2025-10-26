extends Resource
class_name PlayerConfig

@export_category("Camera Configuration")
@export_range(0.001, 0.01, 0.001) var mouse_sensitivity: float = 0.002
@export_range(1.0, 89.0, 1.0) var max_camera_tilt: float = 75.0
@export var max_degree: float = 45
@export var invert_y_axis: bool = false

@export_category("Input Configuration")
@export_range(0.0, 0.5, 0.05) var input_buffer_time: float = 0.1
@export_range(0.0, 1.0, 0.1) var jump_buffer_time: float = 0.15
@export_range(0.0, 1.0, 0.1) var coyote_time: float = 0.1

@export_category("Audio Configuration")
@export var footstep_interval: float = 0.35
@export var volume_db: float = -10.0
