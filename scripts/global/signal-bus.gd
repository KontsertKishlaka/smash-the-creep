extends Node

@warning_ignore_start("unused_signal")

#Сигналы игрока
signal player_damaged(damage: int, source: Node)

# Сигналы сущностей
signal entity_damaged(entity: Node, damage: int, source: Node)
signal entity_died(entity: Node)

# Сигналы разрушаемых объектов
signal destructible_damaged(entity: Node, damage: int, current_health: int, max_health: int)
signal destructible_destroyed(entity: Node)

# Сигналы для системы предметов
signal item_picked_up(item_data: ItemData)
signal weapon_used(weapon_data: WeaponData, player: Player)

# Сигналы для других систем
signal game_over()
