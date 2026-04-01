# Модуль: RBAC (Role-Based Access Control)

> Паттерн многоуровневой системы прав: пресет роли + индивидуальные переопределения.

## Архитектура

```
User
  └─ baseRole → RolePreset (набор permissions)
  └─ permissions[] → UserPermission (GRANT / REVOKE)

Эффективные права = baseRole.permissions + GRANT - REVOKE
```

### Модель данных (Prisma)
```prisma
model RolePreset {
  id          String           @id @default(cuid())
  name        String           @unique        // системное имя (VIEWER, ADMIN)
  displayName String                          // отображаемое (Просмотр, Администратор)
  isSystem    Boolean          @default(false) // нельзя удалить
  permissions RolePermission[]
}

model RolePermission {
  presetId   String
  preset     RolePreset @relation(...)
  permission PermissionCode
  @@unique([presetId, permission])
}

model UserPermission {
  userId     String
  user       User       @relation(...)
  permission PermissionCode
  type       PermissionType   // GRANT | REVOKE
  grantedBy  String?          // кто назначил
  @@unique([userId, permission])
}
```

## Паттерны

### resolvePermissions
```typescript
function resolvePermissions(user: UserWithRelations): Set<PermissionCode> {
  const perms = new Set(user.baseRole?.permissions.map(p => p.permission) ?? []);
  for (const override of user.permissions) {
    if (override.type === "GRANT") perms.add(override.permission);
    if (override.type === "REVOKE") perms.delete(override.permission);
  }
  return perms;
}
```

### requirePermission (API guard)
```typescript
async function requirePermission(code: PermissionCode) {
  const user = await getCurrentUser();
  if (!user) return { ok: false, response: NextResponse.json({ error: "Unauthorized" }, { status: 401 }) };
  const perms = resolvePermissions(user);
  if (!perms.has(code)) return { ok: false, response: NextResponse.json({ error: "Forbidden" }, { status: 403 }) };
  return { ok: true, user, perms };
}
```

### can (проверка в коде)
```typescript
function can(perms: Set<PermissionCode>, code: PermissionCode): boolean {
  return perms.has(code);
}
```

## SSO интеграция

### JIT Provisioning (Just-In-Time)
При SSO-логине:
1. Извлечь AD-группы из JWT claims
2. Найти маппинг AD-группа → RolePreset (по приоритету)
3. Создать/обновить User с `baseRoleId` из маппинга

### Role Override
- Поле `ssoRoleOverride: Boolean` на User
- Поле `ssoResolvedRoleId` — роль, которую SSO назначил бы
- Если `ssoRoleOverride = true` — JIT provisioning обновляет `ssoResolvedRoleId`, но не трогает `baseRoleId`
- В UI показываются обе роли для прозрачности

## Чеклист при добавлении нового permission

1. Добавь в enum `PermissionCode` в schema.prisma
2. Создай миграцию
3. Добавь в соответствующие RolePreset'ы (seed или миграция)
4. Добавь label в `permission-labels.ts`
5. Добавь `requirePermission()` guard в API route
6. Добавь в Zod enum `PermissionCodeEnum`
7. Обнови тесты RBAC
