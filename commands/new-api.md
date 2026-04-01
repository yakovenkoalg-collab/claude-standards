Создай новый API-эндпоинт по стандартам проекта. Аргументы: $ARGUMENTS

## Использование
```
/new-api goals/[id]/metrics POST
/new-api admin/config GET,PUT
/new-api teams CRUD
```

## Шаги

### 1. Разбери аргументы
- **Путь**: `goals/[id]/metrics` → `app/api/goals/[id]/metrics/route.ts`
- **Методы**: `GET`, `POST`, `PUT`, `DELETE` или `CRUD` (= GET + POST на корень, GET + PUT + DELETE на `[id]`)
- Если аргументы не указаны — спроси путь и методы

### 2. Определи Prisma-модель
По имени ресурса найди соответствующую модель в `prisma/schema.prisma`. Если модели нет — спроси, нужно ли создать.

### 3. Создай Zod-схемы
Файл: `lib/api-schemas/models/{entity}.ts` (создай или дополни существующий).

Для каждого метода создай схему:
- **GET (список)**: `{Entity}ListQuery` — query-параметры фильтрации
- **GET (один)**: нет схемы (ID из params)
- **POST**: `{Entity}Create` — обязательные и опциональные поля. Nullable поля в Prisma → `.nullable().optional()` в Zod
- **PUT**: `{Entity}Update` — все поля optional. Nullable → `.nullable().optional()`
- **Response**: `{Entity}Response` — полная схема ответа с relations

Правила:
- `.passthrough()` на Create/Update (для forward-compatibility)
- `.openapi("SchemaName")` на каждой схеме
- FK-поля (`*Id`) → `.cuid()` валидация
- Nullable поля в Prisma (`Type?`) → обязательно `.nullable()` в Create-схеме

### 4. Зарегистрируй в OpenAPI
Файл: `lib/api-schemas/routes/{entity}.ts` (создай или дополни).

Для каждого эндпоинта добавь `registerPath()` с:
- `method`, `path`, `tags`
- `request.body` / `request.query` (ссылка на Zod-схему)
- `responses` (200/201/400/404)

Если файл новый — добавь вызов `register{Entity}Routes()` в `lib/api-schemas/registry.ts`.

### 5. Создай route handler
Файл: `app/api/{path}/route.ts`

Паттерн для каждого метода:
```typescript
export async function METHOD(req: NextRequest, { params }?) {
  try {
    const guard = await requirePermission("PERMISSION_CODE");
    if (!guard.ok) return guard.response;

    // Для POST/PUT: const { data, error } = await parseBody(req, Schema);
    // Для GET с query: const { data, error } = await parseQuery(req, Schema);

    // Prisma query...

    return NextResponse.json(result, { status: 200|201 });
  } catch (error) {
    return handleApiError(error, "METHOD /api/path");
  }
}
```

Для `[id]` роутов: `{ params }: { params: Promise<{ id: string }> }` → `const { id } = await params;`

### 6. Проверь
- `npx tsc --noEmit` — нет ошибок типов
- `npx tsx scripts/check-api-docs.ts` — эндпоинт задокументирован (если скрипт есть)

### 7. Покажи результат
Выведи список созданных/изменённых файлов и подсказку для тестирования через curl.
