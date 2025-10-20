extends Node
class_name HealthSystem

# Параметры здоровья
@export var max_health: int = 5
var current_health: int

# Сигналы для оповещения других систем
signal health_changed(old_value: int, new_value: int)
signal died()

func _ready():
	current_health = max_health

# Метод получения урона
func take_damage(amount: int):
	if amount <= 0:
		return

	var old = current_health
	current_health -= amount
	current_health = max(current_health, 0)
	emit_signal("health_changed", old, current_health)

	if current_health == 0:
		die()

# Метод смерти врага
func die():
	emit_signal("died")
