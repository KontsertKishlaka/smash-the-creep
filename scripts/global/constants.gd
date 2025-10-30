extends Node

# Физические константы
const DEFAULT_GRAVITY = 15.

# Константы для системы толкания
const PUSH_FORCE_MULTIPLIER = 5.
const DEFAULT_CHARACTER_MASS = 80.
const MIN_MASS_RATIO = .25
const PUSH_SOUND_THRESHOLD = 2.  # Минимальная сила для воспроизведения звука

# Компоненты системы
const PUSH_COMPONENT = "PushComponent"

# Слои коллизий
enum LAYERS {
	PLAYER = 1,
	PLAYER_ATTACK = 2,
	ENEMY = 4,
	ENEMY_ATTACK = 8,
	DESTRUCTIBLE = 16,
	WORLD = 32,
	TRIGGER = 64,
	ITEM = 128
}

# Группы
const GROUP_PLAYER = "PLAYER"
const GROUP_ENEMIES = "ENEMY"
const GROUP_DESTRUCTIBLES = "DESTRUCTIBLE"
