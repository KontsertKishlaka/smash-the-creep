extends Node

@export var player: Player
@export var initial_state: String = "idle"

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	print("Player assigned: ", player)
	if not player:
		printerr("Ошибка: Переменная 'player' не привязана к экземпляру Player!")
		return
	
	states["idle"] = preload("uid://c3v2vtgy4wphe").new()
	states["walk"] = preload("uid://dnq45g2phutc").new()
	states["run"] = preload("uid://bxrash0rrq54s").new()
	states["jump"] = preload("uid://bbh2xsts8um7a").new()
	states["attack"] = preload("uid://wa0w8pek53kf").new()
	
	if states.has(initial_state):
		change_state(initial_state)
	else:
		printerr("Ошибка: Начальное состояние '" + initial_state + "' не найдено!")
			
	for state in states.values():
		state.state_machine = self
	
	change_state(initial_state)

func change_state(new_state_name: String):
	if states.has(new_state_name):
		if current_state != null:
			current_state.exit()
		current_state = states[new_state_name]
		if current_state != null:
			current_state.enter()
		else:
			printerr("Ошибка: Состояние '" + new_state_name + "' загружено как null!")
	else:
		printerr("Ошибка: Состояние '" + new_state_name + "' не найдено в словаре states!")

func _physics_process(delta):
	#Отладка связей узлов
	if current_state != null and player:
		current_state.physics_update(delta)

func _process(delta):
	#Отладка связей узлов
	if current_state != null and player:
		current_state.update(delta)
