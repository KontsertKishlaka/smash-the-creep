extends Node
class_name HealthComponent

@export_category("Health Settings")
@export var data: HealthData 
@export_range(0, 10000000, 1) var initial_health: int = 10  # По умолчанию, можно настроить
@export_enum("Player", "Enemy", "Destructible") var entity_type: String = "Enemy"

@export_group("Effects")
@export var death_particle: PackedScene
@export var damage_sound: AudioStream  # Оставим как опцию

@onready var hit_area: Area3D = $HitArea
@onready var damage_sound_player: AudioStreamPlayer3D = $DamageSound  # Может быть null

signal health_changed(old: int, new: int)
signal died()

var current_health: int

func _ready():
	if data:
		current_health = data.current_health if data.current_health > 0 else data.max_health
	else:
		current_health = initial_health
	if entity_type == "Enemy":
		connect("died", Callable(self, "_on_died"))
	if hit_area:
		hit_area.monitoring = true
		if not hit_area.is_connected("body_entered", Callable(self, "_on_hit_area_body_entered")):
			hit_area.connect("body_entered", Callable(self, "_on_hit_area_body_entered"))
	else:
		print("Warning: HitArea not found in HealthComponent!")

func take_damage(damage: int, source: Node = null, damage_type: int = 0):
	if damage <= 0: return
	var old = current_health
	current_health = max(0, current_health - damage)
	emit_signal("health_changed", old, current_health)
	print(get_parent().name, " получил ", damage, " урона от ", source.name if source else "unknown")
	# Проверка на наличие damage_sound_player перед воспроизведением
	if damage_sound and damage_sound_player:
		damage_sound_player.stream = damage_sound
		damage_sound_player.play()
	if current_health <= 0:
		emit_signal("died")
		if entity_type == "Enemy":
			SignalBus.emit_signal("entity_died", get_parent())

func _on_died():
	if death_particle:
		var instance = death_particle.instantiate()
		get_parent().add_child(instance)
		instance.global_transform = get_parent().global_transform

func _on_health_changed(old: int, new: int):
	if entity_type == "Enemy":
		SignalBus.emit_signal("entity_damaged", get_parent(), old - new, null)

func _on_hit_area_body_entered(body: Node):
	if body.has_node("DamageDealer"):
		var dealer = body.get_node("DamageDealer") as DamageDealer
		if dealer and dealer.monitoring:
			take_damage(dealer.damage_amount, body, dealer.damage_types)
