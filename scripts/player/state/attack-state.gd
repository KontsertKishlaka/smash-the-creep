extends PlayerState
class_name AttackState

@onready var hitbox: Area3D = $"../../Camera/PivotArm/Mesh/Hitbox"

var attack_completed: bool = false
var can_combo: bool = false

func enter() -> void:
	animation_player.play("attack_1")
	audio_component.play_attack()
	attack_completed = false
	can_combo = false

	# Подключаем сигналы
	animation_player.connect("animation_finished", _on_animation_finished)
	if animation_player.has_animation("attack_1"):
		animation_player.get_animation("attack_1").loop_mode = Animation.LOOP_NONE

	# Включаем Area3D в середине анимации
	await get_tree().create_timer(0.2).timeout
	if hitbox:
		hitbox.monitoring = true
		hitbox.connect("area_entered", _on_attack_hit)

	# Окно комбо
	await get_tree().create_timer(0.3).timeout
	can_combo = true
	await get_tree().create_timer(0.2).timeout
	can_combo = false

func exit() -> void:
	if hitbox:
		hitbox.monitoring = false
		if hitbox.is_connected("area_entered", _on_attack_hit):
			hitbox.disconnect("area_entered", _on_attack_hit)

	if animation_player.is_connected("animation_finished", _on_animation_finished):
		animation_player.disconnect("animation_finished", _on_animation_finished)

func physics_process(delta: float) -> void:
	# Ограниченное движение во время атаки
	var input_dir = get_movement_input()
	var move_speed = player.player_data.walk_speed * 0.3

	var target_velocity = input_dir * move_speed
	var current_velocity = Vector2(player.velocity.x, player.velocity.z)
	var new_velocity = current_velocity.lerp(Vector2(target_velocity.x, target_velocity.z), 8 * delta)

	player.velocity.x = new_velocity.x
	player.velocity.z = new_velocity.y

	_apply_gravity(delta)
	player.move_and_slide()

	# Проверка комбо-атаки
	if can_combo and Input.is_action_just_pressed("attack"):
		animation_player.play("attack_2")
		can_combo = false
		# Сброс таймеров для второй атаки...

	if attack_completed:
		_transition_from_attack()

func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("attack"):
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
			state_machine.change_state(state_machine.get_node("WalkState"))
		else:
			state_machine.change_state(state_machine.get_node("IdleState"))

func _apply_gravity(delta: float):
	if not player.is_on_floor():
		player.velocity.y -= player.GRAVITY * delta
