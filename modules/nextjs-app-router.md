# Модуль: Next.js App Router паттерны

> Подключи этот блок в CLAUDE.md любого проекта на Next.js 15+ App Router.

## API Routes

### Params
Next.js 15+: `{ params }: { params: Promise<{ id: string }> }` — через `await params`.

### Формат
- CRUD: `GET`/`POST` на `/api/[entity]`, `GET`/`PUT`/`DELETE` на `/api/[entity]/[id]`
- Вложенные: `/api/teams/[id]/goals`, `/api/streams/[id]/members`

## Data Parity (критическое правило)

### Проблема
При добавлении нового поля в UI необходимо обновить **ВСЕ** источники данных — они независимы:
1. SSR `page.tsx` — Prisma query для начальной загрузки
2. API route `route.ts` — Prisma query для client-side refresh
3. Client-side `refreshData()` — fetch к API

Добавление поля в одном месте без остальных = баг (поле undefined при refresh или при SSR).

### Чеклист
- [ ] page.tsx `include` содержит новое поле
- [ ] API route `include` содержит новое поле
- [ ] Client refresh использует правильный URL с нужными query params

## useState(prop) ловушка

### Проблема
```typescript
// ❌ Стейл: prop изменится, но state — нет
const [items, setItems] = useState(initialItems);

// ✅ Вариант 1: используй prop напрямую (если не нужен локальный стейт)
return <List data={initialItems} />;

// ✅ Вариант 2: sync через useEffect
useEffect(() => setItems(initialItems), [initialItems]);
```

### Правило
При добавлении/изменении данных — проверь **каждый** потребляющий компонент: использует prop напрямую (реактивно) или через `useState(prop)` (стейл)?

## Filter Chain Analysis

При добавлении нового фильтра или нового типа данных:
1. Прочитай ВСЕ компоненты, потребляющие отфильтрованные данные
2. Проверь, как каждый существующий фильтр взаимодействует с новым
3. Проверь **дефолтные значения** фильтров — новые данные не должны молча скрываться

## View Modes

Если у страницы несколько режимов отображения (таблица/граф/дерево) — проверь что изменения работают в **КАЖДОМ** режиме.

## Initial Load vs Refresh

SSR `page.tsx` и client-side `refreshData()` должны возвращать **одинаковые** данные (те же поля, те же фильтры). Иначе после refresh UI ломается.
