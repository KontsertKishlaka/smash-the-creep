extends RigidBody3D

@export var health: int = 3

signal broken(box: Node)

func _ready():
	connect("broken", Callable(self, "_on_box_broken"))

func take_hit(damage: int):
	health -= damage
	if health <= 0:
		emit_signal("broken", self)

func _on_box_broken(box):
	# отключаем коллизию и отображение
	$CollisionShape3D.disabled = true
	$MeshInstance3D.visible = false
	# создаём простые "обломки"
	_spawn_fragments()
	# звук
	if has_node("AudioStreamPlayer3D"):
		$AudioStreamPlayer3D.play()
	queue_free()

func _spawn_fragments():
	var debris = preload("uid://w80vffp2pg5k").instantiate()
	debris.global_transform = global_transform
	get_tree().current_scene.add_child(debris)
