extends Node

# Физические константы
const DEFAULT_GRAVITY = 15.0

# Слои коллизий
enum LAYERS {
	PLAYER = 1,
	PLAYER_ATTACK = 2,
	ENEMY = 4,
	ENEMY_ATTACK = 8,
	DESTRUCTIBLE = 16,
	WORLD = 32,
	TRIGGERS = 64,
	ITEMS = 128
}

# Группы
const GROUP_ENEMIES = "ENEMY"
const GROUP_DESTRUCTIBLES = "DESTRUCTIBLE"
