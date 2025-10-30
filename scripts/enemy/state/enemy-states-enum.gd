extends Node
class_name EnemyStatesEnum

enum State {
	PatrolState,
	ChaseState,
	AttackState,
	TakeDamageState,
	DeathState
}

static func get_state_name(value: int) -> String:
	match value:
		State.PatrolState: return "PatrolState"
		State.ChaseState: return "ChaseState"
		State.AttackState: return "AttackState"
		State.TakeDamageState: return "TakeDamageState"
		State.DeathState: return "DeathState"
		_: return "UNKNOWN"
