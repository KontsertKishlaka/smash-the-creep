extends Node

@warning_ignore_start("unused_signal")

#Сигналы игрока
signal player_damaged(damage: int, source: Node)
signal player_attacked(target: Node, damage: int)

# Сигналы сущностей
signal entity_damaged(entity: Node, damage: int, source: Node)
signal entity_died(entity: Node)

# Сигналы разрушаемых объектов
signal destructible_damaged(entity: Node, damage: int, current_health: int, max_health: int)
signal destructible_destroyed(entity: Node)

# Сигналы для системы предметов
signal item_picked_up(item_data: ItemData)
signal weapon_used(weapon_data: WeaponData, player: Player)

# Сигналы для визуальных эффектов
signal spawn_effect(effect_scene: PackedScene, position: Vector3, rotation: Vector3)
signal play_sound(sound: AudioStream, position: Vector3)

# Сигналы для других систем
signal game_over()

# Сигналы аудио
signal play_sound_3d(sound: AudioStream, position: Vector3, volume_db: float, bus: StringName)
signal play_music(music: AudioStream, fade_in_time: float, volume_db: float)
signal stop_music(fade_out_time: float)

# Сигналы управления музыкой
signal toggle_music(enabled: bool)
signal set_music_volume(volume_db: float)
signal scene_music_changed(scene_name: String, music: AudioStream)
