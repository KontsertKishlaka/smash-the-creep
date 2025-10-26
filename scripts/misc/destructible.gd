extends Node3D
class_name Destructible

@export var max_health: int = 3
@export var health: int = 3
@export var break_effect: PackedScene
@export var break_sound: AudioStream
@export var destroy_on_break: bool = true

@onready var mesh: MeshInstance3D = $PivotMesh/Mesh

var original_material: StandardMaterial3D
var is_flashing: bool = false

signal damaged(damage: int, current_health: int, max_health: int)
signal destroyed(node: Node)

func _ready():
	health = max_health
	# Сохраняем оригинальный материал для эффекта вспышки
	if mesh and mesh.get_surface_override_material(0):
		original_material = mesh.get_surface_override_material(0).duplicate()
		mesh.set_surface_override_material(0, original_material)

func take_hit(damage: int = 1):
	if health <= 0:
		return

	health -= damage

	# Эффект белой вспышки
	_play_hit_flash()

	# Логируем удар
	print("Разрушаемый объект получил урон: ", damage, ". Текущее здоровье: ", health, "/", max_health)

	# Отправляем сигналы
	emit_signal("damaged", damage, health, max_health)
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
	emit_signal("destroyed", self)
	SignalBus.emit_signal("destructible_destroyed", self)

	# Эффект разрушения
	if break_effect:
		var fx = break_effect.instantiate()
		fx.global_transform = global_transform
		get_tree().current_scene.add_child(fx)

	# Звук разрушения
	if break_sound:
		var audio = AudioStreamPlayer3D.new()
		audio.stream = break_sound
		audio.global_position = global_position
		get_tree().current_scene.add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

	if destroy_on_break:
		queue_free()
