# Модуль: Zod-валидация + OpenAPI

> Паттерн единых Zod-схем для валидации запросов и генерации OpenAPI-спецификации.

## Структура

```
lib/api-schemas/
  models/          — Zod-схемы сущностей (employee.ts, goal.ts, ...)
  routes/          — OpenAPI-регистрация путей (employees.ts, goals.ts, ...)
  registry.ts      — Центральный реестр, генерирует OpenAPI 3.1
  common.ts        — Общие типы (z, DateTimeString, DateString)
lib/validate.ts    — Хелперы parseBody(), parseQuery()
app/api/openapi.json/route.ts  — Отдаёт спецификацию
app/api-docs/route.ts          — Scalar UI
scripts/check-api-docs.ts      — CI: проверка дрифта
```

## Правила для Zod-схем

### Create-схемы
- Nullable поля в Prisma (`Type?`) → `.nullable().optional()` в Zod
- FK-поля → `.cuid()` валидация
- `.passthrough()` для forward-compatibility
- `.openapi("SchemaName")` на каждой схеме

### Update-схемы
- Все поля `.optional()`
- Nullable → `.nullable().optional()`
- `.passthrough()`

### Response-схемы
- Полная структура с relations
- Nullable поля → `.nullable()`
- Без `.passthrough()`

## Хелперы

```typescript
// lib/validate.ts
export async function parseBody<T>(req: Request, schema: ZodSchema<T>) {
  const body = await req.json().catch(() => null);
  if (!body) return { data: null, error: NextResponse.json({ error: "Invalid JSON" }, { status: 400 }) };
  const result = schema.safeParse(body);
  if (!result.success) return { data: null, error: NextResponse.json({ error: "Validation error", details: result.error.flatten() }, { status: 400 }) };
  return { data: result.data, error: null };
}
```

## Чеклист для нового эндпоинта

1. Создай/обнови Zod-схему в `models/`
2. Добавь `registerPath()` в `routes/`
3. Используй `parseBody(req, schema)` / `parseQuery(req, schema)` в route handler
4. CI (`check-api-docs.ts`) блокирует PR если эндпоинт не задокументирован
