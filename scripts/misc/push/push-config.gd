extends Resource
class_name PushConfig

@export_category("Force Settings")
@export_range(.1, 20., .1) var base_force_multiplier: float = 5.
@export_range(.1, 2., .1) var running_force_multiplier: float = 1.5
@export_range(.1, 2., .1) var crouching_force_multiplier: float = .6

@export_category("Mass Settings")
@export_range(.1, 1., .05) var min_mass_ratio: float = .25
@export_range(.1, 2., .1) var heavy_object_multiplier: float = .7

@export_category("Advanced Physics")
@export var use_advanced_collision: bool = true
@export_range(.0, 1., .05) var friction_wood: float = .3
@export_range(.0, 1., .05) var friction_metal: float = .1
@export_range(.0, 1., .05) var friction_stone: float = .5
