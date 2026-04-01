# Модуль: Prisma 7 с PrismaPg адаптером

> Подключи этот блок в CLAUDE.md любого проекта на Prisma 7 + PostgreSQL.

## Настройка

- `provider = "prisma-client-js"` в `schema.prisma` — **БЕЗ `url`** в datasource block
- URL передаётся через `prisma.config.ts` (для migrate CLI) и `PrismaPg({ connectionString })` (для runtime)
- `serverExternalPackages: ["@prisma/client", "@prisma/adapter-pg", "pg"]` в `next.config.ts`
- Neon pooler vs direct: `prisma migrate deploy` требует прямое подключение (advisory locks). В `prisma.config.ts` используй `DIRECT_DATABASE_URL || DATABASE_URL`

## Критические правила

### Миграции обязательны
После изменения `schema.prisma` (новый enum, поле, таблица) — **ВСЕГДА** создай миграцию. Продакшн использует `prisma migrate deploy`, который запускает только файлы миграций. `db push` — только для прототипирования.

### Relation syntax в update()
PrismaPg адаптер **НЕ принимает скалярные FK** в `update()`. Вместо:
```typescript
// ❌ НЕ работает
await prisma.user.update({ where: { id }, data: { baseRoleId: "..." } });

// ✅ Правильно
await prisma.user.update({
  where: { id },
  data: { baseRole: { connect: { id: "..." } } }
});

// ✅ Для nullable FK — disconnect
await prisma.user.update({
  where: { id },
  data: { employee: { disconnect: true } }
});
```

Скалярные поля (`name`, `isActive`, `Boolean`, `Int`) работают напрямую — ограничение только для relation-полей.

### Регенерация клиента
После `prisma migrate dev` или `prisma generate` — dev-сервер кеширует старый `PrismaClient` в `globalForPrisma`. **Перезапусти dev-сервер**, чтобы новые поля подхватились.

### Проверка дрифта
Перед релизом: `prisma migrate diff --from-config-datasource --to-schema prisma/schema.prisma --script`. Если diff не пустой — создай миграцию.
