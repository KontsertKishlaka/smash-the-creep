@tool
extends Resource
class_name ItemData

# Перечисления
enum ItemType { WEAPON, ARMOR, POTION, MISC }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

# Базовые свойства
@export var id: int = 0                    # Уникальный ID для идентификации
@export var item_name: String = "New Item" # Название
@export var item_type: ItemType = ItemType.MISC : set = set_item_type
@export var rarity: Rarity = Rarity.COMMON
@export var icon: Texture2D                # Иконка для UI
@export_multiline var description: String = "Описание" # Многострочное описание
@export var model: PackedScene             # 3D-модель предмета
@export var weight: float = 1.0            # Вес для инвентаря
@export var value: int = 10                # Стоимость

# Виртуальный метод для поведения (можно переопределить)
func use(_player: Player) -> void:
	push_warning("Метод use() не реализован для %s" % item_name)

# Динамическая настройка типа
func set_item_type(new_type: ItemType) -> void:
	item_type = new_type
	notify_property_list_changed()

# Динамический список свойств для инспектора
func _get_property_list() -> Array:
	var properties = []
	properties.append({"name": "id", "type": TYPE_INT})
	properties.append({"name": "item_name", "type": TYPE_STRING})
	properties.append({"name": "item_type", "type": TYPE_INT, "hint": PROPERTY_HINT_ENUM, "hint_string": ",".join(ItemType.keys())})
	properties.append({"name": "rarity", "type": TYPE_INT, "hint": PROPERTY_HINT_ENUM, "hint_string": ",".join(Rarity.keys())})
	properties.append({"name": "icon", "type": TYPE_OBJECT, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "Texture2D"})
	properties.append({"name": "description", "type": TYPE_STRING, "hint": PROPERTY_HINT_MULTILINE_TEXT})
	properties.append({"name": "model", "type": TYPE_OBJECT, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene"})
	properties.append({"name": "weight", "type": TYPE_FLOAT})
	properties.append({"name": "value", "type": TYPE_INT})
	return properties
