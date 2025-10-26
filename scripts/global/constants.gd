extends Node

# Слои коллизий
enum LAYERS {
	PLAYER = 1,
	ENEMY = 2,
	DESTRUCTIBLE = 4,
	WORLD = 8
}

# Группы
const GROUP_ENEMIES = "enemy"
const GROUP_DESTRUCTIBLES = "destructible"
