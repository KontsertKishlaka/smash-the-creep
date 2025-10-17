@tool
extends ItemData
class_name WeaponData

# Перечисление для типов оружия
enum WeaponType { AXE, SWORD, BOW, STAFF }

# Специфичные свойства оружия
@export var weapon_type: WeaponType = WeaponType.SWORD
@export var damage: int = 10
@export var attack_speed: float = 1.0    # Атаки в секунду
@export var range: float = 1.0           # Дальность в метрах

# Переопределение метода use() для оружия
func use(player) -> void:
	SignalBus.emit_signal("weapon_used", self, player)
	push_warning("%s используется с уроном %d" % [item_name, damage])

# Обновление свойств в инспекторе
func _get_property_list() -> Array:
	var properties = super._get_property_list()
	properties.append({"name": "weapon_type", "type": TYPE_INT, "hint": PROPERTY_HINT_ENUM, "hint_string": ",".join(WeaponType.keys())})
	properties.append({"name": "damage", "type": TYPE_INT})
	properties.append({"name": "attack_speed", "type": TYPE_FLOAT})
	properties.append({"name": "range", "type": TYPE_FLOAT})
	return properties
