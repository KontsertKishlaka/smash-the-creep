extends Node3D
class_name Destructible

@export var max_health: int = 3
@export var health: int = 3
@export var break_effect: PackedScene
@export var break_sound: AudioStream
@export var destroy_on_break: bool = true

@onready var mesh: MeshInstance3D = $PivotMesh/MeshDestructible

var original_material: StandardMaterial3D
var is_flashing: bool = false

func _ready():
	health = max_health

	# Подписываемся на сигналы повреждений через SignalBus
	SignalBus.player_attacked.connect(_on_player_attacked)

	# Сохраняем оригинальный материал для эффекта вспышки
	if mesh and mesh.get_surface_override_material(0):
		original_material = mesh.get_surface_override_material(0).duplicate()
		mesh.set_surface_override_material(0, original_material)

# Метод для получения урона через SignalBus
func _on_player_attacked(target: Node, damage: int):
	# Проверяем, что атака направлена на этот объект
	if target == self:
		print("Сигнальное попадание в разрушаемый объект!")
		_take_hit(damage)

func _take_hit(damage: int = 1):
	if health <= 0:
		return

	health -= damage

	# Эффект белой вспышки
	_play_hit_flash()

	# Логируем удар
	print("Разрушаемый объект получил урон: ", damage, ". Текущее здоровье: ", health, "/", max_health)

	# Отправляем сигналы через SignalBus
	SignalBus.emit_signal("destructible_damaged", self, damage, health, max_health)

	if health <= 0:
		_on_break()

func _play_hit_flash():
	if is_flashing or not mesh or not original_material:
		return

	is_flashing = true

	# Создаем временный материал для вспышки
	var flash_material = original_material.duplicate()
	flash_material.albedo_color = Color.WHITE
	mesh.set_surface_override_material(0, flash_material)

	# Возвращаем оригинальный материал через 0.1 секунды
	await get_tree().create_timer(0.1).timeout

	if mesh:  # Проверяем, что объект еще существует
		mesh.set_surface_override_material(0, original_material)

	is_flashing = false

func _on_break():
	# Логируем разрушение
	print("Разрушаемый объект уничтожен!")

	# Отправляем сигналы
	SignalBus.emit_signal("destructible_destroyed", self)

	# Эффект разрушения через SignalBus → EffectManager
	if break_effect:
		SignalBus.emit_signal("spawn_effect", break_effect, global_position, rotation)

	# Звук разрушения через SignalBus → EffectManager
	if break_sound:
		SignalBus.emit_signal("play_sound", break_sound, global_position, 0.0)

	if destroy_on_break:
		queue_free()
