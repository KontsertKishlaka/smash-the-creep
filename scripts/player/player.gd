extends CharacterBody3D
class_name Player

@export var mouse_sensitivity: float = 0.002
@export var max_degree: float = 45
@export var speed: float = 2
@export var jump_velocity: float = 7
@export var health_points: int = 100

@onready var camera: Camera3D = $Camera


# TEST
@export var target: Destructible


const GRAVITY = 9.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		if camera:
			var current_rotation_x = camera.rotation_degrees.x
			var target_rotation_x = clamp(current_rotation_x - event.relative.y * mouse_sensitivity * 100, -max_degree, max_degree)
			camera.rotation_degrees.x = target_rotation_x
