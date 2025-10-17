extends EnemyState
class_name AttackState

@export var state_enum: int = EnemyStatesEnum.State.AttackState

var attacking_air: bool = false
var attack_cooldown_timer: float = 0.0
var attack_area: Area3D = null

func enter():
	attack_area = slime.get_node("AttackArea")
	attack_area.monitoring = true
	
	attacking_air = true
	attack_cooldown_timer = 0.0
	_attack_player()

func physics_update(delta):
	if not slime.data or not slime.player:
		return

	var to_player = slime.player.global_position - slime.global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	if attacking_air:
		slime.velocity.x = dir.x * slime.data.speed
		slime.velocity.z = dir.z * slime.data.speed
		slime.velocity.y -= slime.data.gravity * delta

		if distance <= slime.data.attack_range or slime.is_on_floor():
			_attack_player()

			var away = (slime.global_position - slime.player.global_position).normalized()
			slime.velocity.x = away.x * slime.data.attack_jump_velocity * slime.data.attack_knockback_horizontal
			slime.velocity.z = away.z * slime.data.attack_jump_velocity * slime.data.attack_knockback_horizontal
			slime.velocity.y = slime.data.attack_jump_velocity * slime.data.attack_knockback_vertical

			attacking_air = false
			attack_cooldown_timer = slime.data.attack_cooldown
			attack_area.monitoring = false

	else:
		slime.velocity.x = move_toward(slime.velocity.x, 0.0, delta * 3.0)
		slime.velocity.z = move_toward(slime.velocity.z, 0.0, delta * 3.0)
		slime.velocity.y -= slime.data.gravity * delta

		if slime.is_on_floor():
			if distance > slime.data.attack_range:
				state_machine.change_state(EnemyStatesEnum.State.ChaseState)

	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

func _attack_player():
	if attack_cooldown_timer > 0.0:
		return

	# --- Дебаг: выводим, кто в зоне атаки ---
	var bodies = attack_area.get_overlapping_bodies()
	print("Bodies in attack area: ", bodies)

	for body in bodies:
		if body == slime.player and slime.player.has_method("take_damage"):
			slime.player.take_damage(slime.data.attack_damage)
			print("Слайм нанес: ", slime.data.attack_damage, " урона!")
