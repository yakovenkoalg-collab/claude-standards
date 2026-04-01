Предпушевая проверка проекта — полный чеклист перед отправкой кода. Аргументы: $ARGUMENTS

## Использование
```
/preflight              # полная проверка
/preflight quick        # только tsc + lint
/preflight moex-portal  # конкретный проект
```

## Шаги

### 1. Определи проект
По текущей директории или из аргументов. Убедись, что есть `package.json`.

### 2. Git status
Покажи `git status` и `git diff --stat`. Предупреди, если есть:
- Незакоммиченные файлы `.env`, `credentials`, `*.key`
- Файлы > 1MB (возможно, бинарники по ошибке)
- Конфликтные маркеры (`<<<<<<<`)

### 3. TypeScript
Запусти `npx tsc --noEmit`. При ошибках — покажи и предложи исправить.

### 4. ESLint (если не `quick`)
Запусти `npx eslint . --ext .ts,.tsx --max-warnings 0` (или `npm run lint`). Основные проблемы:
- `any` вместо конкретных типов
- Неиспользуемые переменные
- Отсутствие `key` в списках
- `<img>` вместо `<Image>`

### 5. Build (если не `quick`)
Запусти `npm run build`. Ловит:
- Ошибки Suspense boundary (которые dev mode пропускает)
- Проблемы prerendering
- Проблемы с dynamic imports

### 6. Unit тесты (если не `quick`)
Запусти `npm run test:unit`. При падениях — покажи какие тесты упали.

### 7. Prisma drift (если есть prisma/)
Запусти `prisma migrate diff --from-config-datasource --to-schema prisma/schema.prisma --script`.
Если diff не пустой — предупреди: **«Есть непокрытые миграциями изменения в schema.prisma»**.

### 8. OpenAPI drift (если есть scripts/check-api-docs.ts)
Запусти `npx tsx scripts/check-api-docs.ts`. Предупреди о незадокументированных эндпоинтах.

### 9. Hardcoded colors (если есть scripts/check-hardcoded-colors.ts)
Запусти проверку. Предупреди о новых hardcoded hex в inline styles.

### 10. Итог
Выведи сводку:
```
✅ TypeScript     — OK
✅ ESLint         — OK
✅ Build          — OK
✅ Unit тесты     — 1095 passed
✅ Prisma         — нет дрифта
✅ OpenAPI        — 395/395 задокументировано
⚠️  Git           — 2 незакоммиченных файла
```

Если всё зелёное — **«Готово к пушу»**. Если есть проблемы — предложи исправления.
