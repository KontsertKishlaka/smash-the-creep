# Стиль коммитов

## Формат коммитов

```bash
<тип>(<область>): <краткое описание>
```

### Типы

- `feat` - Новая функциональность
- `fix` - Исправление ошибки
- `docs` - Изменения в документации
- `refactor` - Изменения кода без исправления ошибок/добавления фич
- `style` - Изменения, не влияющие на логику (форматирование, пробелы)
- `chore` - Изменение структуры проекта, обновление зависимостей/сборки, добавление плагина и т.д.
- `asset` - Добавление/обновление ассетов (для дизайнеров)
- `audio` - Добавление/обновление аудио (для саунд-дизайнеров)

### Области

**Разработка:**

- `player` - Системы игрока
- `enemy` - Системы врагов
- `env` - Системы окружения (объекты, свет)
- `combat` - Боевая система
- `ui` - Пользовательский интерфейс
- `level` - Генерация уровней, окружение
- `inventory` - Инвентарь, экипировка
- `anim` - Анимации
- `proj` - Структура проекта, папки, файлы
- `audio` - Звуки, музыка
- `deps` - Зависимости, плагины

**Дизайн/Саунд-дизайн:**

- `import` - Импорт ассетов
- `model` - 3D модели
- `texture` - Текстуры
- `vfx` - Визуальные эффекты, частицы
- `sfx` - Звуковые эффекты
- `music` - Музыка
- `rig` - Риггинг, скелеты

## Примеры хороших коммитов

**Разработка:**

- `feat(player): add basic move; update jumping | chore(proj): реорганизация папок ассетов по типам`
- `fix(enemy): remove player tracking through walls | feat(inventory): optimize item sorting`
- `fix(enemy): remove slime corners stucking`
- `refactor(inventory): optimize scripts`
- `chore(proj): restruct assets dirs`
- `chore(deps): add markdown supporting plugin`

**Дизайн/Саунд-дизайн:**

- `asset(import): env props`
- `asset(vfx): base attack particles`
- `fix(audio): normalize footstep volume`
- `asset(anim): basic player idle/run anims`
- `asset(texture): update player model albedo map`
- `asset(rig): add player rig`
- `fix(model): the barrel model UV-map`
- `asset(model): add basic player model`

> 💬 Железное правило: "Чем кратче - тем лучше" \:)
> А описание (body) коммита пишется ТОЛЬКО при необходимости/при желании

---

<div align="center">
  <span>© 2025 <a href="https://github.com/KontsertKishlaka" target="_blank">KontsertKishlaka</a></span>
  <br>
  <span><i>slash-the-creep - единый стиль коммитов</i></span>
</div>
