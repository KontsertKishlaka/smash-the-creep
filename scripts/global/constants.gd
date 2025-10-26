extends Node

# Физические константы
const DEFAULT_GRAVITY = 15.0

# Слои коллизий
enum LAYERS {
	PLAYER = 1,
	ENEMY = 2,
	DESTRUCTIBLE = 4,
	WORLD = 8
}

# Группы
const GROUP_ENEMIES = "ENEMY"
const GROUP_DESTRUCTIBLES = "DESTRUCTIBLE"
