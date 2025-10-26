extends PlayerState
class_name AttackState

@onready var hitbox: Area3D = $"../../Camera/PivotArm/Mesh/Hitbox"
var attack_completed: bool = false

func enter() -> void:
	animation_player.play("attack_1")
	audio_component.play_attack()
	attack_completed = false

	# Подключаем сигнал завершения анимации
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

	# Включаем Area3D в середине анимации
	await get_tree().create_timer(0.2).timeout
	if hitbox:
		hitbox.monitoring = true
		if not hitbox.area_entered.is_connected(_on_attack_hit):
			hitbox.area_entered.connect(_on_attack_hit)

func exit() -> void:
	if hitbox:
		hitbox.monitoring = false
		if hitbox.area_entered.is_connected(_on_attack_hit):
			hitbox.area_entered.disconnect(_on_attack_hit)

	if animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)

func physics_process(delta: float) -> void:
	# Ограниченное движение во время атаки
	var input_dir = get_movement_input()
	var camera_relative_dir = player.get_camera_relative_direction(input_dir)
	var move_speed = player.player_data.walk_speed * 0.3

	var target_velocity = camera_relative_dir * move_speed
	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 8 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

	# Переход после завершения атаки
	if attack_completed:
		_transition_from_attack()

func _on_animation_finished(anim_name: String):
	if anim_name == "attack_1":
		attack_completed = true

func _on_attack_hit(area: Area3D):
	var hit_layer = area.collision_layer

	if hit_layer & Constants.LAYERS.ENEMY:
		print("Попадание по врагу: ", area.name)
		SignalBus.emit_signal("entity_damaged", area.get_parent(), player.player_data.base_attack_damage, player)

	elif hit_layer & Constants.LAYERS.DESTRUCTIBLE:
		print("Попадание по разрушаемому объекту: ", area.name)
		SignalBus.emit_signal("entity_damaged", area.get_parent(), player.player_data.base_attack_damage, player)

func _transition_from_attack():
	if not player.is_on_floor():
		state_machine.change_state(state_machine.get_node("FallState"))
	else:
		var input_dir = get_movement_input()
		if input_dir.length() > 0:
			if Input.is_action_pressed("sprint"):
				state_machine.change_state(state_machine.get_node("RunState"))
			else:
				state_machine.change_state(state_machine.get_node("WalkState"))
		else:
			state_machine.change_state(state_machine.get_node("IdleState"))
