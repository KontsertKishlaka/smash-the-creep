extends EnemyState
class_name AttackState

@export var state_enum: int = EnemyStatesEnum.State.AttackState

var attacking_air: bool = false
var attack_cooldown_timer: float = 0.0
var attack_area: Area3D = null
var target: Node3D = null
var is_bouncing: bool = false
var bounce_target: Node3D = null

func enter():
	attack_area = slime.get_node("AttackArea")
	attack_area.monitoring = true
	
	if not attack_area.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
		attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
	if not attack_area.is_connected("body_exited", Callable(self, "_on_attack_area_body_exited")):
		attack_area.connect("body_exited", Callable(self, "_on_attack_area_body_exited"))

	attacking_air = true
	attack_cooldown_timer = 0.0
	target = null
	is_bouncing = false
	bounce_target = null

	print(slime.name, " - перешёл в AttackState")

func physics_update(delta):
	if not slime.data or not is_instance_valid(slime):
		return

	if (target == null or not is_instance_valid(target)) and is_bouncing and is_instance_valid(bounce_target):
		_update_bounce(delta)
		return
	elif target == null or not is_instance_valid(target):
		state_machine.change_state(EnemyStatesEnum.State.ChaseState)
		return

	var to_target = target.global_position - slime.global_position
	var distance = to_target.length()
	var dir = to_target.normalized()

	if attacking_air:
		slime.velocity.x = dir.x * slime.data.speed
		slime.velocity.z = dir.z * slime.data.speed
		slime.velocity.y -= slime.data.gravity * delta

		if distance <= slime.data.attack_range or slime.is_on_floor():
			_perform_attack()

			is_bouncing = true
			bounce_target = target
			attacking_air = false
			attack_cooldown_timer = slime.data.attack_cooldown
			attack_area.monitoring = false

	else:
		if is_bouncing and is_instance_valid(bounce_target):
			_update_bounce(delta)
		else:
			slime.velocity.x = move_toward(slime.velocity.x, 0.0, delta * 3.0)
			slime.velocity.z = move_toward(slime.velocity.z, 0.0, delta * 3.0)
			slime.velocity.y -= slime.data.gravity * delta

			if slime.is_on_floor() and distance > slime.data.attack_range:
				state_machine.change_state(EnemyStatesEnum.State.ChaseState)

	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

func _on_attack_area_body_entered(body):
	if body is Player and body.has_method("take_damage"):
		print(slime.name, " - обнаружил игрока: ", body.name)
		target = body

func _on_attack_area_body_exited(body):
	if body == target:
		print("Игрок покинул зону атаки: ", body.name)
		target = null

func _perform_attack():
	if attack_cooldown_timer > 0.0 or not is_instance_valid(target):
		return

	if target.has_method("take_damage"):
		target.take_damage(slime.data.attack_damage)
		print(slime.name, " нанёс ", slime.data.attack_damage, " урона игроку ", target.name)
	else:
		print("Игрок не имеет метода take_damage, пропускаем атаку")

func _update_bounce(_delta):
	if not is_instance_valid(bounce_target):
		is_bouncing = false
		return

	# Отталкивание от цели
	var away = (slime.global_position - bounce_target.global_position).normalized()
	slime.velocity.x = away.x * slime.data.attack_jump_velocity * slime.data.attack_knockback_horizontal
	slime.velocity.z = away.z * slime.data.attack_jump_velocity * slime.data.attack_knockback_horizontal
	slime.velocity.y = slime.data.attack_jump_velocity * slime.data.attack_knockback_vertical

	# Завершаем отталкивание при приземлении
	if slime.is_on_floor():
		is_bouncing = false
		bounce_target = null
