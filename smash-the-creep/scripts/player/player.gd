extends CharacterBody3D
class_name Player


@export_category("Player Params")  
@export var player_data: PlayerData
@export_category("Player Config")  
@export var player_config: PlayerConfig

@onready var camera: Camera3D = $Camera

# TEST
@export var target: Destructible

const GRAVITY = 9.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * player_config.mouse_sensitivity)

		if camera:
			var current_rotation_x = camera.rotation_degrees.x
			var target_rotation_x = clamp(current_rotation_x - event.relative.y * player_config.mouse_sensitivity * 100, -player_config.max_degree, player_config.max_degree)
			camera.rotation_degrees.x = target_rotation_x

func _physics_process(_delta: float) -> void:
	# TEST
	if Input.is_action_just_pressed("attack"):
		if target and target.has_method("take_hit"):
			target.take_hit(1)
