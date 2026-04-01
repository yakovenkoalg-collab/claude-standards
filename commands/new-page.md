Создай новую страницу в Next.js App Router проекте по стандартам. Аргументы: $ARGUMENTS

## Использование
```
/new-page capacity "Управление ёмкостью"
/new-page admin/audit "Журнал аудита"
/new-page teams/[id]/budget "Бюджет команды"
```

## Шаги

### 1. Разбери аргументы
- **Путь**: `capacity` → `app/capacity/page.tsx`
- **Название**: для breadcrumbs, заголовка, документации
- Если не указаны — спроси

### 2. Определи тип страницы
- **Список** (без `[id]`): SSR page.tsx + client компонент + API fetch
- **Деталь** (`[id]`): SSR page.tsx с Prisma query + client компонент
- **Форма** (`new` или `[id]/edit`): client компонент с формой

### 3. Создай page.tsx (серверный компонент)
```typescript
import { Metadata } from "next";
// Для защищённых страниц:
import { requirePermission } from "@/lib/access";

export const metadata: Metadata = {
  title: "Название — Портал",
};

export default async function PageName() {
  const guard = await requirePermission("PERMISSION_CODE");
  if (!guard.ok) redirect("/");

  // Prisma query...

  return <ClientComponent data={data} />;
}
```

Для `[id]` страниц: `{ params }: { params: Promise<{ id: string }> }`.

### 4. Создай клиентский компонент
Файл: `components/{section}/{ComponentName}.tsx`

Включи:
- `"use client";`
- `<PageHeader>` с заголовком и breadcrumbs
- Skeleton-загрузка для async данных
- Обработку пустого состояния (`<EmptyState>`)
- Dark theme через CSS-переменные (НЕ hardcoded hex)

### 5. Обнови документацию

**`lib/docs-context.ts`**: добавь маппинг в `PATHNAME_TO_SECTION`:
```typescript
"/путь": "section-id",
```

**`lib/docs-content.ts`**: добавь секцию в `DOC_SECTIONS` с описанием страницы. Включи секцию в соответствующую группу в `DOC_NAV_GROUPS`.

### 6. Обнови навигацию
Если страница должна быть в sidebar — добавь пункт в `components/layout/Sidebar.tsx`.
Проверь, нужен ли permission check для показа/скрытия пункта меню.

### 7. Проверь
- `npx tsc --noEmit`
- Открой страницу в браузере
- Проверь dark theme
- Проверь мобильный вид

### 8. Покажи результат
Выведи список созданных файлов и URL для проверки.
