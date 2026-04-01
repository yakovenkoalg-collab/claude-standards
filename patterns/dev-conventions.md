# Паттерн: Конвенции разработки

> Единые правила для всех проектов. Подключай в CLAUDE.md.

## Git

### Коммиты
- `feat:` — новая функциональность
- `fix:` — исправление бага
- `refactor:` — рефакторинг без изменения поведения
- `chore:` — инфраструктура, зависимости, CI
- `release: v{X.Y.Z}` — релизный коммит

### Ветвление
- `main` — стабильная ветка, автодеплой через Vercel
- Feature branches: `feature/{номер}-{slug}` или работа прямо в main (для solo-разработки)
- PR для review при работе в команде

### Деплой
- `[deploy]` маркер в сообщении коммита → Vercel запускает билд
- Маркер должен быть в **последнем** коммите пуша (Vercel проверяет только HEAD)
- Решение о деплое принимается явно после push (не автоматически)

## TypeScript

### Типизация
- **Никогда `any`**: объекты → `Record<string, unknown>`, Prisma enum → каст к конкретному типу
- Recharts formatter: `(value: number | string, name: string)`
- Неиспользуемые переменные: удалять. В деструктуризации массива — пропуск через `,`

### ESLint
- `eslint-disable` только блочный `/* */`, не `//`
- Нельзя читать `ref.current` во время рендера (React 19)
- `<Image>` из `next/image` вместо `<img>`

## API

### Обработка ошибок
```typescript
try {
  // ...
} catch (error) {
  return handleApiError(error, "METHOD /api/path");
}
```

### Валидация
- Входные данные: `parseBody(req, schema)` / `parseQuery(req, schema)`
- Не доверять клиенту — валидировать на сервере
- Zod `.passthrough()` на Create/Update для forward-compatibility

### Аудит
- Все мутации (POST/PUT/DELETE) → `logAudit()`
- Permission changes → `emitEvent()` для уведомлений
- Privilege changes → `invalidateUserSessions()`

## UI уведомления

### Toast, не alert
```typescript
// ❌
alert("Сохранено!");

// ✅
const toast = useToast();
toast.success("Сохранено");
toast.apiError(err, "Ошибка сохранения");
toast.error("Что-то пошло не так");
toast.info("Подсказка");
```

## Тестирование

### Префикс E2E данных
Каждая создаваемая в E2E сущность **ДОЛЖНА** начинаться с `E2E ` — для auto-cleanup.

### Cleanup
```typescript
const cleanup = createCleanup();
test.afterEach(async ({ request }) => { await cleanup.run(request); });
// cleanup.track('teams', team.id);
```

### Seed данные
Не мутировать. Если тест обновляет seed-запись — восстановить в `afterEach`.

## Документация

### При добавлении страницы
1. `lib/docs-context.ts` → `PATHNAME_TO_SECTION`
2. `lib/docs-content.ts` → `DOC_SECTIONS` + `DOC_NAV_GROUPS`

### При добавлении API
1. Zod-схема + `registerPath()` + `parseBody/parseQuery`
2. CI блокирует PR без документации

## Защита данных

### Dev DB
**НИКОГДА** не удалять/менять production-данные в dev DB без прямого указания пользователя. Всегда спрашивать перед деструктивными операциями.

### Чувствительные данные
Не коммитить: `.env`, `credentials.json`, `*.key`, пароли. Git pre-commit hook должен это проверять.
