extends Area3D
class_name DamageDealer

@export var damage_amount: int = 10
@export_flags("Physical:1", "Fire:2", "Poison:4") var damage_types: int = 1
@export var cooldown: float = 0.5

var timer: Timer
var can_damage: bool = true

func _ready():
	timer = Timer.new()
	timer.wait_time = cooldown
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_cooldown_end"))
	add_child(timer)
	monitoring = false  # По умолчанию off
	collision_mask = 1  # Player layer by default

func activate():
	monitoring = true
	if can_damage:
		can_damage = false
		timer.start()

func deactivate():
	monitoring = false

func _on_body_entered(body: Node):
	if monitoring and can_damage and body.has_node("HealthComponent"):
		var health = body.get_node("HealthComponent")
		health.take_damage(damage_amount, get_parent(), damage_types)

func _on_cooldown_end():
	can_damage = true
