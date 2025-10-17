extends Node
class_name EnemyStatesEnum

enum State {
	PatrolState,
	ChaseState,
	AttackState,
	DeathState
}

static func get_state_name(value: int) -> String:
	match value:
		State.PatrolState: return "PatrolState"
		State.ChaseState: return "ChaseState"
		State.AttackState: return "AttackState"
		State.DeathState: return "DeathState"
		_: return "UNKNOWN"
