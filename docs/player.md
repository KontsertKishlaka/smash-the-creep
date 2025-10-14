# Игрок: базовый вид

## 🎯 Структура сцены

```md
Player (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
├── Pivot (Node3D)
├── Camera3D
├── StateMachine (Node)
├── HealthSystem (Node)
└── InventorySystem (Node)
```

## 🧩 Ключевые компоненты

| Компонент            | Скрипт                       | Паттерн     | Назначение                                         |
| -------------------- | ---------------------------- | ----------- | -------------------------------------------------- |
| **Player**           | `player.gd`                  | Композиция  | Корневой узел, управляет всеми системами           |
| **State Machine**    | `state_machine.gd` + states/ | Состояния   | Управление поведением (движение, атака, уклонение) |
| **Health System**    | `health_system.gd`           | -           | Здоровье, урон, смерть, неуязвимость               |
| **Inventory System** | `inventory_system.gd`        | -           | Предметы, оружие, экипировка                       |
| **Player Data**      | `player_data.gd`             | Ресурсы     | Данные: здоровье, статы, инвентарь                 |
| **Signal Bus**       | `signal_bus.gd`              | Наблюдатель | Глобальная связь между системами                   |

## 📊 Данные игрока (PlayerData)

```gdscript
extends Resource
class_name PlayerData

@export var max_health: int = 100
@export var current_health: int = 100
@export var speed: float = 10.0
@export var gravity: float = 30.0
@export var inventory: Array[ItemResource] = []
```

## 📡 Ключевые сигналы

- `player_health_changed(old_value, new_value)`
- `player_died()`
- `item_picked(item_resource)`
- `update_health_ui(current_health, max_health)`

## 💡 Основные состояния

- **MoveState**
- **JumpState**
- **AttackState**
- **DeathState**

---

<div align="center">
  <span>© 2025 <a href="https://github.com/KontsertKishlaka" targer="_blank">KontsertKishlaka</a></span>
  <br>
  <span><i>Slasher RPG — базовая спецификация персонажа</i></span>
</div>
