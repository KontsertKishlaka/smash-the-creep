<div align="center">
  <img src="./.media/stc-cover-us.png" alt="Smash the Creep Cover" title="Смеш-зе-Крипщина"/>
  <h1>😜 Игрок: Базовый вид</h1>
  <h3><i>Smash the Creep</i></h3>
  <q><i>В мире, где слизь не прощает ошибок, герой рождается с мечом - и каплей надежды.</i></q>
  <br>
  <br>

![Godot](https://img.shields.io/badge/Engine-Godot-blue?logo=godot-engine&logoColor=white "Годотщина") ![Blender](https://img.shields.io/badge/Model-Blender-orange?logo=blender&logoColor=white "Блендерщина")<br>![Player](https://img.shields.io/badge/Docs-Player-yellow?logo=readme&logoColor=white "Рлауэр") ![Status](https://img.shields.io/badge/Status-In--Progress-ffff00?logo=devbox&logoColor=white "Статус документа") ![Team](https://img.shields.io/badge/Team-KontsertKishlaka-purple?logo=refinedgithub&logoColor=white "Кислак")

</div>

---

## 📹 Структура сцены

```md
Player (CharacterBody3D)
├── CollisionBody (CollisionShape3D)
├── AttackArea (Area3D)
│   └── CollisionAttack (CollisionShape3D)
├── TakeDamageArea (Area3D)
│   └── CollisionTakeDamage (CollisionShape3D)
├── Pivot (Node3D)
│   └── Model (Node3D / MeshInstance3D)
├── Camera (Camera3D)
├── StateMachine (Node)
├── HealthSystem (Node)
└── InventorySystem (Node)
```

> _💬 В будущем также будут добавлены:_ > _- `SpotSystem` (система онаружения врагов/предметов/НПС)_ > _- `UISystem` (система отображения UI: характеристики, инвентарь, древо перков)_

---

## 📝 Данные [Игрока](../scripts/player/player-data.gd "Player resources: PlayerData")

**Пример:**

```gdscript
extends Resource
class_name PlayerData

@export_category("Movement")
@export var speed: float = 10.0
@export var jump_velocity: float = 7

@export_category("Health")
@export var max_health: int = 100
@export var current_health: int = 100

@export_category("Inventory")
@export var inventory: Array[ItemResource] = []
```

<!-- Вместо `@export_category("...")`, возможно, нужно использовать `@export_group("...")` -->

---

## 📝 Конфиг [Игрока](../scripts/player/player-config.gd "Player resources: PlayerConfig")

**Пример:**

```gdscript
extends Resource
class_name PlayerConfig

@export_category("Input")
@export var mouse_sensitivity: float = 0.002

@export_category("Screen")
@export var max_degree: float = 45
```

<!-- Вместо `@export_category("...")`, возможно, нужно использовать `@export_group("...")` -->

---

## 📡 Ключевые сигналы (косвенная связь с [SignalBus](../scripts/global/signal-bus.gd "Singleton: SignalBus"))

Финальный список ещё обсуждается. **Пока имеем следующие сигналы:**

**Сигналы `HealthSystem`:** _(MUST HAVE)_

- `signal player_health_changed(old_value, new_value)`
- `signal player_damaged(damage, source)`
- `signal player_died()` или `signal game_over()`
- `signal item_picked(item_resource)`

**Сигналы `InventorySystem`:** _(SHOULD HAVE)_

- `signal item_picked_up(item_data)`
- `signal weapon_used(weapon_data, player)`
- `signal player_damaged(damage, source)`

**Сигналы `SpotSystem`:** _(COULD HAVE)_

- `signal enemy_spotted(enemy)` (нужен отдельный компонент - `SpotRange` (`Area3D`))

**Сигналы `UISystem`:** _(COULD HAVE)_

- `signal update_health_ui(current_health, max_health)`

---

## 😵‍💫 Состояния [Игрока](../scripts/player/player-state-machine.gd "Player: StateMachine")

- [idle](../scripts/player/player-states/idle-state.gd "Состояние: Бездействие")
- [walk](../scripts/player/player-states/walk-state.gd "Состояние: Ходьба")
- [run](../scripts/player/player-states/run-state.gd "Состояние: Бег")
- [jump](../scripts/player/player-states/jump-state.gd "Состояние: Прыжок")
- [take_damage](../scripts/player/player-states/take-damage-state.gd "Состояние: Получение урона") _(SHOULD HAVE)_
- [death](../scripts/player/player-states/death-state.gd "Состояние: Смерть") _(SHOULD HAVE)_

---

## 🎨 [Игрок](./design/player/player-design.md "Player: Design") в Blender

Подробнее о 3Д модельке Игрока и анимациях: [Дизайн Игрока](./design/player/player-design.md "Игрок: Дизайн")

---

<div align="center">
  <sub>© 2025 <a href="https://github.com/KontsertKishlaka" target="_blank">KontsertKishlaka</a> - Smash the Creep</sub>
  <br>
  <sup><i>“Базовая спецификация Игрока”</i></sup>
</div>
