extends Node

#region Физика
const DEFAULT_GRAVITY = 15.0
#endregion

#region Массы
const MASS_PLAYER: float = 80.0
const MASS_SLIME: float = 40.0
const MASS_BOX: float = 20.0
const MASS_BARREL: float = 60.0
const MASS_ROCK: float = 120.0
#endregion

#region Cистема толкания
const PUSH_FORCE_MULTIPLIER: float = 5.0
const MIN_MASS_RATIO: float = .25
const PUSH_SOUND_THRESHOLD: float = 2.0
#endregion

#region Компоненты
const PUSH_COMPONENT: StringName = &"PushComponent"
#endregion

#region Слои коллизий
enum COLLISION_LAYER {
	PLAYER = 1,
	PLAYER_ATTACK = 2,
	ENEMY = 4,
	ENEMY_ATTACK = 8,
	DESTRUCTIBLE = 16,
	WORLD = 32,
	TRIGGER = 64,
	ITEM = 128
}
#endregion

#region Группы
const GROUP_PLAYER: StringName = &"PLAYER"
const GROUP_ENEMY: StringName = &"ENEMY"
const GROUP_DESTRUCTIBLE: StringName = &"DESTRUCTIBLE"
#endregion

#region Состояния StateMachine
const STATE_IDLE: StringName = &"IdleState"
const STATE_WALK: StringName = &"WalkState"
const STATE_RUN: StringName = &"RunState"
const STATE_JUMP: StringName = &"JupmState"
const STATE_FALL: StringName = &"FallState"
const STATE_ATTACK: StringName = &"AttackState"
const STATE_TAKE_DAMAGE: StringName = &"TakeDamageState"
const STATE_DEATH: StringName = &"DeathState"
#const STATE_PATROL: StringName = &"PatrolState"
#endregion

#region Анимации
const ANIM_IDLE: StringName = &"idle"
const ANIM_WALK: StringName = &"walk"
const ANIM_RUN: StringName = &"run"
const ANIM_JUMP: StringName = &"jump"
const ANIM_FALL: StringName = &"fall"
const ANIM_ATTACK_1: StringName = &"attack_1"
const ANIM_ATTACK_2: StringName = &"attack_2"
const ANIM_TAKE_DAMAGE: StringName = &"take_damage"
const ANIM_DEATH: StringName = &"death"
#endregion
