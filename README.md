<div align="center">
  <img src="docs/.media/stc-cover.png" alt="Smash the Creep Cover"/>
  <h1>🗡️ Smash the Creep</h1>
  <h3><i>3D Action Roguelike на Godot 4.5</i></h3>
  <q><i>В мире, где слизь не прощает ошибок, герой рождается с мечом - и каплей надежды.</i></q>
  <br>
  <br>

![Godot](https://img.shields.io/badge/Engine-Godot-blue?logo=godot-engine&logoColor=white) ![Readme](https://img.shields.io/badge/Docs-README-yellow?logo=readme&logoColor=white) ![Status](https://img.shields.io/badge/Status-Pre--Alpha-orange?logo=github)<br>![License](https://img.shields.io/badge/License-MIT-ffff00?logo=instacart&logoColor=white) ![Contrib](https://img.shields.io/badge/Contribs-Welcome-brightgreen?logo=github&logoColor=white) ![Team](https://img.shields.io/badge/Team-KontsertKishlaka-purple?logo=refinedgithub&logoColor=white)

</div>

---

## 🎮 Описание

**Smash the Creep** - это атмосферный 3D-экшен с элементами **RPG** и **рогалика**, созданный на **Godot 4.5**.  

Игроку предстоит:

- Исследовать процедурно сгенерированные уровни
- Сражаться с волнами существ и мини-боссами
- Собирать лут, артефакты и выстраивать билд
- Прокачивать способности через перки и экипировку

---

## ⚙️ Ключевые особенности

| Система             | Описание                                          |
| ------------------- | ------------------------------------------------- |
| 🗡️ **Боевая**       | Комбо-атаки, урон по зонам, взаимодействие стихий |
| 🧠 **ИИ врагов**    | State Machine, паттерны поведения, фазы боссов    |
| 💎 **Лут и перки**  | Механика сборок, сетовые бонусы, прокачка         |
| 🌍 **Мир**          | Процедурная генерация, биомы, ловушки             |
| 💰 **Экономика**    | Сундуки, торговцы, валюта                         |
| 🔔 **События**      | Случайные и глобальные ивенты                     |
| 📜 **Документация** | Подробное описание в `docs/`                      |

---

## 🔁 Геймплейный цикл

```mermaid
flowchart LR
  A([Начало уровня]) --> B{Исследование мира}
  B -->|Находит врага| C[⚔️ Бой]
  C -->|Победа| D[💎 Лут и опыт]
  D -->|Улучшение| E[🧙 Прокачка персонажа]
  E -->|Продвижение| F[🌍 Следующий биом]
  F -->|Смерть| G([💀 Конец рана])
  G -->|Повторить| A
```

---

## 🧩 Архитектура проекта

```mermaid
flowchart LR
  P["Игрок"] --> SBus[SignalBus]
  E["Враг"] --> SBus
  SBus --> Sys[Система: Боёвка, Лут, AI]
  Sys --> Rsrc[Resource Data]
  Rsrc --> PlayerData
  Rsrc --> EnemyData
```

---

## 🏗️ Структура проекта

```mermaid
graph LR
  Root[📁 slash-the-creep] --> Asset[🗂️ assets]
  Root --> Scenes[😜 scenes]
  Root --> Scripts[🎮 scripts]
  Root --> Docs[📚 docs]
  Docs --> B[👻 backlog]
  Docs --> P[🤖 prompts]
  Docs --> M[mechs-and-systems.md]
  Docs --> G[setup-guide.md]
  Docs --> CS[commit-guide.md]
  Asset --> AU[🛎️ audio]
  Asset --> T[🎨 textures]
  Asset --> VFX[💥 vfx]
```

---

## 🚀 Начало работы

Для инструкции по установке и первому запуску: [docs/setup-guide.md](./docs/setup-guide.md)

---

## 📅 Бэклог и планирование

Текущая неделя:
**MVP: базовое взаимодействие Игрока и Врага**: [docs/backlog/01-backlog.md](./docs/backlog/01-backlog.md)

Планирование ведётся по методике **MoSCoW** (Must / Should / Could / Won’t Have).

---

## 👥 Авторы проекта

| Участник     | Роль                                                                                     | Ссылка                                                |
| ------------ | ---------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| 🧀 Влад      | Руководитель проекта, Разработка, Аналитика, Документация, Саунд-дизайн, "Сырная власть" | [MindlessMuse666](https://github.com/MindlessMuse666) |
| 🔪 Егор      | Разработка, Креатив, «Ответственный за чёлку»                                            | [nineteentearz](https://github.com/nineteentearz)     |
| 😜 Каракалбе | Разработка, Креатив, «Ответственный за Слаймов»                                          | [bukabtw](https://github.com/bukabtw)                 |
| 🐢 Саша      | Разработка, «Администрация баз данных»                                                   | [FrierenWay](https://github.com/FrierenWay)           |
| 🎨 Дженна    | Художник, Дизайн, 3D-моделирование, «Карточная мафия»                                    | [Jenko-zhulenko](https://github.com/Jenko-zhulenko)   |
| 🌸 Аня       | Дизайн, 3D-дизайн, «Аня»                                                                 | Анонимно, администрации печенья                       |

> Отдельное спасибо **Бастрыкину** за знания, мотивацию и вайб - [ks54.ru](https://www.ks54.ru/)

---

## 📄 Лицензия

Проект распространяется под лицензией **MIT**.
См. [LICENSE](./LICENSE)

---

<div align="center">
  <sub>© 2025 <a href="https://github.com/KontsertKishlaka" target="_blank" >KontsertKishlaka</a> - Smash the Creep</sub>
  <br>
  <sup><i>“Made with Love and Godotshina 4.5”</i></sup>
</div>
