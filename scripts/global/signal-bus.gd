extends Node

#Сигналы игрока
signal player_damaged(damage, source)

# Сигналы для системы предметов
signal item_picked_up(item_data)
signal weapon_used(weapon_data, player)

# Сигналы для других систем (пример)
signal enemy_spotted(enemy)
signal game_over()

func _ready():
	# Инициализация (опционально)
	pass
