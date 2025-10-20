extends Node
class_name PlayerStateMachine

@export var player: Player
@export var player_data: PlayerData
@export var initial_state: String = "idle"

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	print("Player assigned: ", player)
	if not player:
		printerr("Ошибка: Переменная 'player' не привязана к экземпляру Player!")
		return

	states["idle"] = preload("res://scripts/player/player-states/idle-state.gd").new()
	states["walk"] = preload("res://scripts/player/player-states/walk-state.gd").new()
	states["run"] = preload("res://scripts/player/player-states/run-state.gd").new()
	states["jump"] = preload("res://scripts/player/player-states/jump-state.gd").new()
	states["attack"] = preload("res://scripts/player/player-states/attack-state.gd").new()

	for state_name in states:
		if not states[state_name]:
			printerr("Ошибка: Состояние '", state_name, "' не удалось загрузить!")
			return

	for state in states.values():
		state.state_machine = self
		state.player = player
		state.player_data = player_data
		if player and player.has_node("DamageDealer"):
			state.damage_dealer = player.get_node("DamageDealer")
			print("DamageDealer передан: ", state.damage_dealer)
		else:
			printerr("Ошибка: Узел DamageDealer не найден в Player!")

	if states.has(initial_state):
		change_state(initial_state)
	else:
		printerr("Ошибка: Начальное состояние '" + initial_state + "' не найдено!")

func change_state(new_state_name: String):
	if states.has(new_state_name):
		if current_state:
			current_state.exit()
		current_state = states[new_state_name]
		if current_state:
			current_state.enter()
		else:
			printerr("Ошибка: Состояние '" + new_state_name + "' загружено как null!")
	else:
		printerr("Ошибка: Состояние '" + new_state_name + "' не найдено в словаре states!")

func _physics_process(delta):
	if current_state and player:
		current_state.physics_update(delta)
		_handle_movement(delta, player.is_on_floor())

func _process(delta):
	if current_state and player:
		current_state.update(delta)

func _handle_movement(delta, is_on_floor: bool = false, air_drag: float = 1.0, air_acceleration: float = 0.0, max_air_speed: float = 0.0):
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("move_forwards"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backwards"):
		input_dir.z += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1

	var velocity = player.velocity
	var speed_multiplier = 1.0
	if current_state == states["run"]:
		speed_multiplier = 2.0

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		var direction = (player.transform.basis * input_dir).normalized()
		if not is_on_floor:
			var desired_velocity = direction * max_air_speed
			velocity.x = move_toward(velocity.x, desired_velocity.x, air_acceleration * delta)
			velocity.z = move_toward(velocity.z, desired_velocity.z, air_acceleration * delta)
			var horizontal_velocity = Vector2(velocity.x, velocity.z)
			horizontal_velocity *= air_drag
			velocity.x = horizontal_velocity.x
			velocity.z = horizontal_velocity.y
		else:
			if player_data:
				velocity.x = direction.x * player_data.speed * speed_multiplier
				velocity.z = direction.z * player_data.speed * speed_multiplier
			else:
				printerr("Ошибка: player_data не привязан, используется значение по умолчанию (5.0)")
				velocity.x = direction.x * 5.0 * speed_multiplier
				velocity.z = direction.z * 5.0 * speed_multiplier
	else:
		if is_on_floor:
			velocity.x = 0
			velocity.z = 0

	if not is_on_floor:
		velocity.y -= player.GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor:
		change_state("jump")
		velocity.y = player_data.jump_velocity if player_data else 10.0
	if Input.is_action_pressed("attack"):
		change_state("attack")

	if is_on_floor:
		if input_dir.length() > 0:
			if Input.is_action_pressed("sprint"):
				change_state("run")
			else:
				change_state("walk")
		else:
			change_state("idle")

	player.velocity = velocity
	player.move_and_slide()
