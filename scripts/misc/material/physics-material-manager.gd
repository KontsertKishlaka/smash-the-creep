extends Node

# Словарь для хранения материалов
var _materials: Dictionary = {}

func _ready():
	_load_materials()
	print("🌿 PhysicsMaterialManager инициализирован с %d материалами" % _materials.size())

func _load_materials():
	var materials_folder = "res://assets/material/physics/"

	#region Валидация
	# Проверяем существование папки
	if not DirAccess.dir_exists_absolute(materials_folder):
		push_error("❌ PhysicsMaterialManager: Директория '%s' не существует!" % materials_folder)
		return

	var dir = DirAccess.open(materials_folder)
	if not dir:
		push_error("❌ PhysicsMaterialManager: Не могу открыть директорию '%s'" % materials_folder)
		return

	# Начинаем перебор файлов
	var error = dir.list_dir_begin()
	if error != OK:
		push_error("❌ PhysicsMaterialManager: Ошибка чтения директории")
		return
	#endregion

	var file_name = dir.get_next()
	var loaded_count = 0

	while file_name != "":
		# Пропускаем папки и файлы не .tres
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var material_path = materials_folder.path_join(file_name)
			var material: PhysicsMaterialResource = load(material_path)

			if material and material is PhysicsMaterialResource:
				_materials[material.material_name] = material
				loaded_count += 1
				print("✅ Загружен физический материал: %s из %s" % [material.material_name, file_name])
			else:
				push_warning("⚠️ Не удалось загрузить физический материал: %s" % file_name)

		file_name = dir.get_next()

	dir.list_dir_end()

	if loaded_count == 0:
		push_warning("⚠️ Физические материалы не найдены в папке")

# Публичное API
func get_material(material_name: String) -> PhysicsMaterialResource:
	return _materials.get(material_name, null)

func get_friction(material_name: String) -> float:
	var material = get_material(material_name)
	if material:
		return material.friction
	push_warning("⚠️ PhysicsMaterialManager: Материал '%s' не найден, возвращаю трение по умолчанию" % material_name)
	return 0.4  # Дефолтное трение

func get_bounciness(material_name: String) -> float:
	var material = get_material(material_name)
	if material:
		return material.bounciness
	push_warning("⚠️ PhysicsMaterialManager: Материал '%s' не найден, возвращаю отскок по умолчанию" % material_name)
	return 0.2  # Дефолтный отскок

func get_impact_sounds(material_name: String) -> Array[AudioStream]:
	var material = get_material(material_name)
	if material:
		return material.impact_sounds
	return []  # Пустой массив если материал не найден

# Вспомогательные методы
func has_material(material_name: String) -> bool:
	return _materials.has(material_name)

func get_available_materials() -> Array[String]:
	return _materials.keys()

func get_materials_count() -> int:
	return _materials.size()
