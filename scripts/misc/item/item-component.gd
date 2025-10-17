extends Area3D
class_name ItemComponent

@export var item_data: ItemData

func _ready() -> void:
	if not item_data:
		push_error("ItemComponent: Отсутствует item_data!")
		return
	# Настройка 3D-модели из item_data.model
	if item_data.model:
		var model_instance = item_data.model.instantiate()
		add_child(model_instance)
	connect_signals()

func connect_signals() -> void:
	SignalBus.connect("player_interact", _on_player_interact)

func _on_player_interact(player) -> void:
	if not is_instance_valid(player) or not overlaps_body(player):
		return
	item_data.use(player)
	SignalBus.emit_signal("item_picked_up", item_data)
	queue_free()  # Удаляем предмет после использования
