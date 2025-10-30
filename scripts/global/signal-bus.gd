extends Node

@warning_ignore_start("unused_signal")

#region Игрок
signal player_damaged(damage: int, source: Node)
signal player_attacked(target: Node, damage: int)
#endregion

#region Враг
signal enemy_damaged(enemy: Node, damage: int, source: Node)
signal enemy_died(enemy: Node)
#endregion

#region Здоровье
signal health_changed(entity: Node, current_health: int, max_health: int)
signal invincibility_started(entity: Node, duration: float)
signal invincibility_ended(entity: Node)
#endregion

#region Физика
signal rigidbody_pushed(rigidbody: RigidBody3D, pusher: Node3D, force: Vector3)
signal rigidbody_collision(collider: RigidBody3D, character: CharacterBody3D, force: float)
signal push_sound_played(position: Vector3, force: float, pusher_type: String)
signal rigidbody_impact_sound(position: Vector3, impact_force: float, material_type: String)
#endregion

#region Разрушаемые объекты
signal destructible_damaged(entity: Node, damage: int, current_health: int, max_health: int)
signal destructible_destroyed(entity: Node)
#endregion

#region Предметы
signal item_picked_up(item_data: ItemData)
signal weapon_used(weapon_data: WeaponData, player: Player)
#endregion

#region Аудио
signal play_sound(sound: AudioStream, position: Vector3)
signal play_sound_3d(sound: AudioStream, position: Vector3)
signal play_music(music: AudioStream)
signal stop_music()
signal toggle_music(enabled: bool)
signal set_music_volume(volume_db: float)
signal scene_music_changed(scene_name: String, music: AudioStream)
#endregion

#region Системные
signal spawn_effect(effect_scene: PackedScene, position: Vector3, rotation: Vector3)
signal game_over()
#endregion
