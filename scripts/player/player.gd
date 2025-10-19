extends CharacterBody3D
class_name Player

@export_category("Player Params")  
@export var player_data: PlayerData
@export_category("Player Config")  
@export var player_config: PlayerConfig

@onready var camera: Camera3D = $Camera
@onready var hit_area: Area3D = $HitArea  # Ссылка на HitArea (Area3D)

# TEST
@export var target: Destructible

const GRAVITY = 9.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Подключаем сигналы для HitArea
	if hit_area:
		hit_area.monitoring = true
		if not hit_area.is_connected("body_entered", Callable(self, "_on_hit_area_body_entered")):
			hit_area.connect("body_entered", Callable(self, "_on_hit_area_body_entered"))

	# Подключаем сигнал player_damaged из SignalBus
	if not SignalBus.is_connected("player_damaged", Callable(self, "_on_player_damaged")):
		SignalBus.connect("player_damaged", Callable(self, "_on_player_damaged"))

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

# Метод для обработки получения урона
func take_damage(damage: float, source: Node = null):
	if player_data:
		player_data.health -= damage
		print("Игрок получил ", damage, " урона от ", source.name if source else "неизвестного источника")
		SignalBus.emit_signal("player_damaged", damage, source)
		if player_data.health <= 0:
			print("Игрок умер!")
			SignalBus.emit_signal("game_over")

# Обработчик сигнала player_damaged из SignalBus
func _on_player_damaged(damage: float, source: Node):
	print("Сигнал player_damaged: Игрок получил ", damage, " урона от ", source.name if source else "неизвестного источника")

# Обработчик столкновения с HitArea
func _on_hit_area_body_entered(body: Node):
	if body is Enemy and body.has_method("get_attack_damage"):
		var damage = body.get_attack_damage()
		take_damage(damage, body)
