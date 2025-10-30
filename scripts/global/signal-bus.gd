extends Node

@warning_ignore_start("unused_signal")

# Сигналы игрока
signal player_damaged(damage: int, source: Node)
signal player_attacked(target: Node, damage: int)

# Сигналы врагов
signal enemy_damaged(enemy: Node, damage: int, source: Node)
signal enemy_died(enemy: Node)

# Сигналы здоровья
signal health_changed(entity: Node, current_health: int, max_health: int)
signal invincibility_started(entity: Node, duration: float)
signal invincibility_ended(entity: Node)

# Сигналы разрушаемых объектов
signal destructible_damaged(entity: Node, damage: int, current_health: int, max_health: int)
signal destructible_destroyed(entity: Node)

# Сигналы для системы предметов
signal item_picked_up(item_data: ItemData)
signal weapon_used(weapon_data: WeaponData, player: Player)

# Сигналы для аудио
signal play_sound(sound: AudioStream, position: Vector3)
signal play_sound_3d(sound: AudioStream, position: Vector3)
signal play_music(music: AudioStream)
signal stop_music()
signal toggle_music(enabled: bool)
signal set_music_volume(volume_db: float)
signal scene_music_changed(scene_name: String, music: AudioStream)

# Сигналы для других систем
signal spawn_effect(effect_scene: PackedScene, position: Vector3, rotation: Vector3)
signal game_over()
