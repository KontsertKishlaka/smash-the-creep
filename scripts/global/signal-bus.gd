extends Node

@warning_ignore_start("unused_signal")

#Сигналы игрока
signal player_damaged(damage, source)

signal entity_damaged(entity: Node, damage: int, source: Node)
signal entity_died(entity: Node)

# Сигналы для системы предметов
signal item_picked_up(item_data)
signal weapon_used(weapon_data, player)

# Сигналы для других систем (пример)
signal game_over()
