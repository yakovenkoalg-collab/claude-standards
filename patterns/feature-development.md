# Паттерн: Разработка фичи от дизайна до релиза

> Чеклист и порядок действий для реализации нетривиальной задачи.

## Этапы

### 1. Дизайн-документ (`/design-doc`)
**Когда:** задача затрагивает > 3 файлов или вводит новую сущность/паттерн.

Обязательные секции:
- Цель (одно предложение)
- Инвентаризация данных (все места чтения/записи)
- Карта компонентов (кто потребляет данные)
- Модель данных (Prisma changes)
- Стыки (какие существующие файлы менять)

### 2. Модель данных
```
schema.prisma → миграция → prisma generate → перезапуск dev
```
- Nullable поля: `Type?` в Prisma = `.nullable().optional()` в Zod
- Enum: добавить в Prisma + Zod + labels
- Relation: обратная связь в обеих моделях

### 3. API
Порядок: Zod-схема → OpenAPI регистрация → Route handler → Тест.

```
/new-api {path} {methods}
```

### 4. UI
Порядок: Server page → Client component → Docs.

```
/new-page {path} "{title}"
```

Правила:
- Dark theme: CSS-переменные, не hex
- Accessibility: ARIA roles, label linkage
- Responsive: mobile-first, touch targets 44px
- Loading: Skeleton, не пустой экран
- Empty state: EmptyState с action

### 5. Тестирование
| Изменение | Тест |
|-----------|------|
| Новый API | Smoke (OpenAPI) + E2E для POST/PUT/DELETE |
| RBAC | `tests/unit/rbac/access.test.ts` |
| Новая страница | `tests/e2e/{page}.spec.ts` + Page Object |
| Бизнес-логика | Unit в `tests/unit/business/` |
| Bug fix | Регрессионный тест |

### 6. Предпушевая проверка
```
/preflight
```
- TypeScript, ESLint, Build, Unit тесты
- Prisma drift, OpenAPI drift
- Hardcoded colors

### 7. Релиз
```
/release {project}
```

## Антипаттерны (чего НЕ делать)

### Data parity
❌ Добавить поле в API route, забыть в page.tsx SSR query.
✅ Обновить ВСЕ источники данных одновременно.

### useState(prop)
❌ `useState(initialProp)` без sync useEffect.
✅ Использовать prop напрямую или добавить useEffect sync.

### Фильтры скрывают данные
❌ Добавить новый статус, забыть проверить дефолты фильтров.
✅ Проверить каждый фильтр: показывает ли новые данные по умолчанию?

### Один view mode
❌ Проверить изменения только в таблице, забыть про граф.
✅ Проверить ВСЕ режимы отображения.

### Hardcoded hex
❌ `style={{ backgroundColor: "#FEE2E2" }}` — сломает dark theme.
✅ CSS-переменные или isDark switch.

### alert() вместо toast
❌ `alert("Сохранено!")` — блокирует UI.
✅ `toast.success("Сохранено")` — неблокирующее уведомление.
