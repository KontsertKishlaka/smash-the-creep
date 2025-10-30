# Враг: базовый вид

🎯 Структура сцены

```md
Enemy (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
├── Pivot (Node3D)
├── StateMachine (Node)
├── HealthSystem (Node)
├── AttackSystem (Node)
└── VisionArea (Area3D)
```

## 🧩 Ключевые компоненты

| Компонент     | Скрипт                             | Паттерн     | Назначение                                                   |
| ------------- | ---------------------------------- | ----------- | ------------------------------------------------------------ |
| Enemy         | `enemy.gd`                         | Композиция  | Корневой узел, управляет всеми системами врага               |
| State Machine | `enemy_state_machine.gd` + states/ | Состояния   | Управление поведением (патрулирование, преследование, атака) |
| Health System | `health_system.gd`                 | -           | Здоровье, получение урона, смерть                            |
| Attack System | `attack_system.gd`                 | Стратегия   | Управление атаками (ближними и дальними)                     |
| Enemy Data    | `enemy_data.gd`                    | Ресурсы     | Данные: здоровье, урон, скорость, тип атаки                  |
| Signal Bus    | `signal_bus.gd`                    | Наблюдатель | Глобальная связь (сигналы от врагов)                         |

## 📊 Данные врага (EnemyData)

```gdscript
extends Resource
class_name EnemyData

@export var enemy_type: String = "melee" # "melee" или "ranged"
@export var max_health: int = 50
@export var current_health: int = 50
@export var speed: float = 5.0
@export var gravity: float = 30.0
@export var damage: int = 10
@export var attack_range: float = 2.0
@export var projectile_scene: PackedScene # для дальних атак
```

## 📡 Ключевые сигналы

- `enemy_died(enemy)`
- `enemy_health_changed(enemy, old_value, new_value)`
- `enemy_attack_player(damage)`

## 💡 Основные состояния врага

- **IdleState** - ожидание/патрулирование
- **ChaseState** - преследование игрока
- **AttackState** - выполнение атаки
- **DeathState** - смерть и исчезновение

## 🎯 Конкретные реализации

### Слайм (ближний бой)

```gdscript

# slime_data.gd

extends EnemyData
class_name SlimeData

@export var bounce_force: float = 8.0
@export var attack_windup: float = 0.5
```

### Морозный паук (ближний + дальний бой)

```gdscript

# frost_spider_data.gd

extends EnemyData
class_name FrostSpiderData

@export var poison_damage: int = 5
@export var poison_duration: float = 3.0
@export var ranged_cooldown: float = 3.0
```

## 🎮 Система атак (AttackSystem)

### Базовые классы атак

```gdscript

# attack_strategy.gd

class_name AttackStrategy
extends Node

func can_attack(target: Node3D) -> bool:
pass

func execute_attack():
pass
```

### Конкретные стратегии

#### Ближний бой (`melee_attack.gd`)

```gdscript

extends AttackStrategy

func execute_attack(): # Логика ближней атаки (таран)
pass
```

#### Дальний бой (`ranged_attack.gd`)

```gdscript
extends AttackStrategy

func execute_attack(): # Логика дальней атаки (плевок ядом)
pass
```

---

<div align="center">
  <span>© 2025 <a href="https://github.com/KontsertKishlaka" targer="_blank">KontsertKishlaka</a></span>
  <br>
  <span><i>slash-the-creep - спецификация врага</i></span>
</div>
