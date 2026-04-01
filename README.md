# claude-standards

Переиспользуемые скиллы, модули и паттерны для Claude Code.

## Что внутри

### `commands/` — Slash-команды
Копируются в `.claude/commands/` проекта. Доступны как `/command-name`.

| Файл | Команда | Назначение |
|------|---------|-----------|
| `audit-schemas.md` | `/audit-schemas` | Аудит Zod vs Prisma nullable/optional |
| `design-doc.md` | `/design-doc` | Дизайн-документ перед реализацией |
| `new-api.md` | `/new-api` | Scaffold API endpoint (route + schema + OpenAPI) |
| `new-page.md` | `/new-page` | Scaffold страницы App Router |
| `preflight.md` | `/preflight` | Предпушевая проверка (tsc, build, tests, drift) |
| `release.md` | `/release` | Полный пайплайн релиза (version, changelog, migrations, tests, push, deploy) |

### `modules/` — Инструкции по стеку
Копируются в `docs/claude-modules/`. Ссылки добавляются в CLAUDE.md проекта.

| Файл | Тема |
|------|------|
| `prisma7.md` | PrismaPg адаптер, relation syntax, миграции, drift |
| `nextjs-app-router.md` | Data parity, useState(prop), filter chain, view modes |
| `rbac.md` | Роли + права + SSO + переопределения |
| `validation-openapi.md` | Zod + OpenAPI registry + CI drift check |
| `ui-dark-theme.md` | CSS-переменные, dark theme, accessibility, компоненты |

### `patterns/` — Паттерны разработки
Копируются в `docs/claude-patterns/`.

| Файл | Тема |
|------|------|
| `roadmap-management.md` | roadmap.json, статусы, волны, changelog |
| `feature-development.md` | Полный цикл: дизайн → код → тесты → релиз |
| `dev-conventions.md` | Git, TypeScript, API, тесты, защита данных |

## Подключение к проекту

### Первая установка
```bash
cd your-project
/sync-standards install https://github.com/your-org/claude-standards
```

### Обновление
```bash
/sync-standards pull    # Подтянуть обновления из claude-standards
/sync-standards push    # Отправить изменения обратно в claude-standards
/sync-standards status  # Показать различия
```

### Без Claude Code
```bash
git clone https://github.com/your-org/claude-standards /tmp/cs
cp /tmp/cs/commands/* .claude/commands/
cp /tmp/cs/modules/* docs/claude-modules/
cp /tmp/cs/patterns/* docs/claude-patterns/
echo "1.0.0" > .claude-standards-version
```

## Принцип

**Проект самодостаточен.** Все файлы копируются в git проекта — никаких submodules, symlinks или внешних зависимостей. `claude-standards` — upstream для мейнтейнера, не зависимость для разработчика.
