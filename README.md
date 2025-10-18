<div align="center">
  <img src="docs/.media/stc-cover-us.png" alt="Smash the Creep Cover" title="Смеш-зе-Крипщина"/>
  <h1>🗡️ Smash the Creep</h1>
  <h3><i>3D Action Roguelike на Godot 4.5</i></h3>
  <q><i>В мире, где слизь не прощает ошибок, герой рождается с мечом - и каплей надежды.</i></q>
  <br>
  <br>

![Godot](https://img.shields.io/badge/Engine-Godot-blue?logo=godot-engine&logoColor=white "Додот") ![Readme](https://img.shields.io/badge/Docs-README-yellow?logo=readme&logoColor=white "Этот документ") ![Status](https://img.shields.io/badge/Status-Pre--Alpha-orange?logo=github "Статус проекта")<br>![License](https://img.shields.io/badge/License-MIT-ffff00?logo=instacart&logoColor=white "Лицензия MIT") ![Contribution](https://img.shields.io/badge/Contribs-Welcome-brightgreen?logo=github&logoColor=white "Открыто для предложений") ![Team](https://img.shields.io/badge/Team-KontsertKishlaka-purple?logo=refinedgithub&logoColor=white "Кислакщина")

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

Инструкция по установке и первому запуску: [Быстрый старт](./docs/setup-guide.md "Быстрый старт")

---

## 📅 Бэклог и планирование

**Методология:** Agile Scrum с элементами Kanban

**Бэклог текущей недели:** [Базовое взаимодействие Игрока, Врага и Сцены](./docs/backlog/01-backlog.md "Бэклог: неделя №1")

**Планирование:** MoSCoW (Must / Should / Could / Won’t Have)

---

## 👥 Авторы проекта

| Участник     | Роль                                                                                     | Ссылка                                                |
| ------------ | ---------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| 🧀 Влад      | Руководитель проекта, Разработка, Аналитика, Документация, Саунд-дизайн, «Сырная власть» | [MindlessMuse666](https://github.com/MindlessMuse666 "Сырная власть") |
| 🔪 Егор      | Разработка, Креатив, «Ответственный за чёлку»                                            | [nineteentearz](https://github.com/nineteentearz "Ответственный за чёлку")     |
| 😜 Каракалбе | Разработка, Креатив, «Ответственный за слаймов»                                          | [bukabtw](https://github.com/bukabtw "Ответственный за слаймов")                 |
| 🐢 Саша      | Разработка, «Администрация баз данных»                                                   | [FrierenWay](https://github.com/FrierenWay "Администрация баз данных")           |
| 🎨 Дженна    | Художник, Дизайн, 3D-моделирование, «Карточная мафия»                                    | [Jenko-zhulenko](https://github.com/Jenko-zhulenko)   |
| 🌸 Аня       | Дизайн, 3D-дизайн, «Аня»                                                                 | [Анонимно, администрации печенья](./assets/audio/nya.mp3 "Анонимно, администрации печенья")                       |

> 💬 Отдельное спасибо **Бастрыкину** за знания, мотивацию и вайб - [ks54.ru](https://www.ks54.ru "Караклассика & Метакаракелн 🧐🎩")

---

## 📄 Лицензия

Проект распространяется под лицензией [MIT](./LICENSE "Лицензия MIT")

---

<div align="center">
  <sub>© 2025 <a href="https://github.com/KontsertKishlaka" target="_blank" title="Кислакщинащина">KontsertKishlaka</a> - Smash the Creep</sub>
  <br>
  <sup><i>“Made with <b>Love</b> and <b>Godotshina</b>”</i></sup>
</div>
