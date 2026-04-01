# Модуль: UI, Dark Theme и Accessibility

> Правила для компонентов, тёмной темы и доступности.

## Dark Theme

### CSS-переменные (всегда безопасны)
```css
--bg-canvas, --bg-panel, --bg-card, --bg-elevated, --bg-subtle
--text-primary, --text-secondary, --text-tertiary
--border-soft, --border-strong
--accent-primary, --accent-hover, --accent-soft
```

Legacy aliases: `--background`, `--card-bg`, `--muted`, `--foreground`, `--border`. Предпочитай новые имена.

### Запрет hardcoded hex
**Inline styles с `backgroundColor: "#FEE2E2"` ломают dark theme.** Паттерн:
```typescript
// ❌
style={{ backgroundColor: "#FEE2E2", color: "#991B1B" }}

// ✅ Вариант 1: CSS-переменные
className="bg-[var(--bg-subtle)] text-[var(--text-primary)]"

// ✅ Вариант 2: isDark switch (для data-viz и badges)
const { theme } = useTheme();
const isDark = theme === "dark";
style={isDark ? { backgroundColor: "#7F1D1D", color: "#FCA5A5" } : { backgroundColor: "#FEE2E2", color: "#991B1B" }}
```

### Recharts
- `<Pie>` label: custom renderer с `fill={isDark ? "#cbd5e1" : "#374151"}`
- `<Tooltip>`: `contentStyle={{ backgroundColor: "var(--card-bg)", color: "var(--foreground)" }}`

## UI-компоненты

### Обязательные
| Кейс | Компонент |
|------|-----------|
| Кнопки | `<Button variant="..." size="...">` |
| Ошибки форм | `<InlineError message={...}>` + `aria-describedby` |
| Загрузка | `<Skeleton>` |
| Пустое состояние | `<EmptyState icon={...} message="..." action={...}>` |
| Модалки | `<Modal>` с focus trap |
| Табы | `<Tabs>` с arrow/Home/End навигацией |
| Подтверждение | `<ConfirmDialog>` с `role="alertdialog"` |
| Поиск с выбором | `<Combobox>` (single/multi) |
| Таблицы | `<ResponsiveTable>` с приоритетами колонок |
| Icon-кнопки | `<IconButton label="...">` (44px touch target) |
| Уведомления | `useToast()` — НЕ `alert()` |

### Формы в модалках
НЕ сбрасывать стейт через useEffect. Паттерн:
```typescript
// На родителе — key для пересоздания:
<Form key={open ? (editingItem?.id ?? "new") : "closed"} />

// В форме — useState с initialValue:
const [name, setName] = useState(editingItem?.name ?? "");
```

## Accessibility

### ARIA
- Modal: `role="dialog"`, `aria-modal="true"`, `aria-labelledby`
- Tabs: `role="tablist"` + `role="tab"` + `aria-selected`
- Inputs: `<label htmlFor="X">` + `<input id="X">` + `aria-required` + `aria-invalid`

### Responsive
- Touch targets: 44px minimum
- Мобильный layout по умолчанию, desktop в `md:`/`lg:`
- `<PageHeader>` для всех top-level страниц
