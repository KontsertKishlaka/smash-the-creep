extends Node
class_name EnemyStatesEnum

enum State {
	PatrolState,
	ChaseState,
	AttackState,
	TakeDamageState,
	DeathState,
	IdleState
}

enum DeathType {
	DISSOLVE,
	EXPLODE, 
	SINK,
	FADE
}

static func get_state_name(value: int) -> String:
	match value:
		State.PatrolState: return "PatrolState"
		State.ChaseState: return "ChaseState"
		State.AttackState: return "AttackState"
		State.TakeDamageState: return "TakeDamageState"
		State.DeathState: return "DeathState"
		State.IdleState: return "IdleState"
		_: return "UNKNOWN"

static func get_death_type_name(value: int) -> String:
	match value:
		DeathType.DISSOLVE: return "DISSOLVE"
		DeathType.EXPLODE: return "EXPLODE"
		DeathType.SINK: return "SINK" 
		DeathType.FADE: return "FADE"
		_: return "UNKNOWN_DEATH_TYPE"
