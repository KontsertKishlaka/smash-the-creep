class_name HealthSystem

var _current_health: int
var _max_health: int
var _is_invincible: bool = false
var _invincibility_timer: float = 0.0

var _owner: Node
var _entity_name: String

func _init(owner: Node, entity_name: String, max_hp: int):
	_owner = owner
	_entity_name = entity_name
	_max_health = max_hp
	_current_health = max_hp

func take_damage(amount: int, source: Node = null) -> void:
	if _is_invincible or _current_health <= 0:
		return
	
	_current_health -= amount
	_current_health = max(0, _current_health)
	
	var source_name: String = "неизвестно"
	if source and source is Node:
		source_name = source.name
	
	print("%s получил %d урона от %s. Здоровье: %d/%d" % [
		_entity_name, amount, source_name, _current_health, _max_health
	])
	
	if _owner is Enemy:
		SignalBus.enemy_damaged.emit(_owner, amount, source)
	elif _owner is Player:
		SignalBus.player_damaged.emit(amount, source)  # Ваш сигнал ожидает (damage, source)
		
	SignalBus.health_changed.emit(_owner, _current_health, _max_health)

	_start_invincibility(0.5)

	if _current_health <= 0:
		_die(source)

func _start_invincibility(duration: float) -> void:
	if duration <= 0:
		return
	
	_is_invincible = true
	_invincibility_timer = duration
	SignalBus.invincibility_started.emit(_owner, duration)

func _update_invincibility(delta: float) -> void:
	if _is_invincible:
		_invincibility_timer -= delta
		if _invincibility_timer <= 0:
			_is_invincible = false
			SignalBus.invincibility_ended.emit(_owner)

func _die(killer: Node = null) -> void:
	print("%s умер!" % _entity_name)
	
	if _owner is Enemy:
		SignalBus.enemy_died.emit(_owner)
	elif _owner is Player:
		# Для игрока используем game_over сигнал
		SignalBus.game_over.emit()
	
	if _owner.has_method("_on_death"):
		_owner._on_death(killer)

func get_current_health() -> int:
	return _current_health

func get_max_health() -> int:
	return _max_health

func get_health_percentage() -> float:
	return float(_current_health) / float(_max_health)

func is_alive() -> bool:
	return _current_health > 0

func is_invincible() -> bool:
	return _is_invincible

func update(delta: float) -> void:
	_update_invincibility(delta)
