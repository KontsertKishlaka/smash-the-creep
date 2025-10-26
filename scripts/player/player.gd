extends CharacterBody3D
class_name Player

@export_category("Player Resources")
@export var player_data: PlayerData
@export var player_config: PlayerConfig

@onready var camera: Camera3D = $Camera
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $Animation

const GRAVITY = 9.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup_attack_area()

func setup_attack_area():
	var attack_area = $Camera/PivotArm/Mesh/Hitbox
	attack_area.collision_mask = Constants.LAYERS.ENEMY | Constants.LAYERS.DESTRUCTIBLE
	attack_area.monitoring = false

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * player_config.mouse_sensitivity)
		if camera:
			var current_tilt = camera.rotation.x
			var target_tilt = current_tilt - event.relative.y * player_config.mouse_sensitivity
			camera.rotation.x = clamp(target_tilt, -player_config.max_degree, player_config.max_degree)
