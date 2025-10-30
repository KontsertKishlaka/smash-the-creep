@tool
extends ItemData
class_name WeaponData


enum WeaponType { AXE, SWORD, BOW, STAFF }

@export var weapon_type: WeaponType = WeaponType.SWORD

func use(player) -> void:
	SignalBus.emit_signal("weapon_used", self, player)

func _get_property_list() -> Array:
	var properties = super._get_property_list()
	properties.append({"name": "weapon_type", "type": TYPE_INT, "hint": PROPERTY_HINT_ENUM, "hint_string": ",".join(WeaponType.keys())})
	properties.append({"name": "damage", "type": TYPE_INT})
	properties.append({"name": "attack_speed", "type": TYPE_FLOAT})
	properties.append({"name": "range", "type": TYPE_FLOAT})
	return properties
