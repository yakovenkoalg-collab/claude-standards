#!/bin/bash
set -euo pipefail

# sync.sh — Синхронизация claude-standards с проектом
# Использование:
#   ./sync.sh install <project-dir>  — первая установка в проект
#   ./sync.sh pull <project-dir>     — обновить проект из standards
#   ./sync.sh push <project-dir>     — обновить standards из проекта
#   ./sync.sh status <project-dir>   — показать различия

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ACTION="${1:-status}"
PROJECT_DIR="${2:-.}"

# Resolve absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
  echo "❌ Директория не найдена: $2"
  exit 1
}

COMMANDS_SRC="$SCRIPT_DIR/commands"
MODULES_SRC="$SCRIPT_DIR/modules"
PATTERNS_SRC="$SCRIPT_DIR/patterns"

COMMANDS_DST="$PROJECT_DIR/.claude/commands"
MODULES_DST="$PROJECT_DIR/docs/claude-modules"
PATTERNS_DST="$PROJECT_DIR/docs/claude-patterns"

VERSION_FILE="$SCRIPT_DIR/VERSION"
PROJECT_VERSION_FILE="$PROJECT_DIR/.claude-standards-version"

show_diff() {
  local src="$1" dst="$2" label="$3"
  local changed=0

  for f in "$src"/*.md; do
    [ -f "$f" ] || continue
    local name="$(basename "$f")"
    local target="$dst/$name"
    if [ ! -f "$target" ]; then
      echo "  + $label/$name (новый)"
      changed=1
    elif ! diff -q "$f" "$target" >/dev/null 2>&1; then
      echo "  ~ $label/$name (изменён)"
      changed=1
    fi
  done

  # Files in dst but not in src
  if [ -d "$dst" ]; then
    for f in "$dst"/*.md; do
      [ -f "$f" ] || continue
      local name="$(basename "$f")"
      if [ ! -f "$src/$name" ]; then
        echo "  ? $label/$name (только в проекте)"
        changed=1
      fi
    done
  fi

  return $changed
}

copy_files() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  for f in "$src"/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "$dst/"
  done
}

case "$ACTION" in
  install)
    echo "📦 Установка claude-standards в $PROJECT_DIR"
    mkdir -p "$COMMANDS_DST" "$MODULES_DST" "$PATTERNS_DST"
    copy_files "$COMMANDS_SRC" "$COMMANDS_DST"
    copy_files "$MODULES_SRC" "$MODULES_DST"
    copy_files "$PATTERNS_SRC" "$PATTERNS_DST"
    cp "$VERSION_FILE" "$PROJECT_VERSION_FILE"
    echo "✅ Установлено: $(cat "$VERSION_FILE" | tr -d '\n')"
    echo "   commands → .claude/commands/"
    echo "   modules  → docs/claude-modules/"
    echo "   patterns → docs/claude-patterns/"
    ;;

  pull)
    echo "⬇️  Обновление проекта из claude-standards"
    copy_files "$COMMANDS_SRC" "$COMMANDS_DST"
    copy_files "$MODULES_SRC" "$MODULES_DST"
    copy_files "$PATTERNS_SRC" "$PATTERNS_DST"
    cp "$VERSION_FILE" "$PROJECT_VERSION_FILE"
    echo "✅ Обновлено до $(cat "$VERSION_FILE" | tr -d '\n')"
    ;;

  push)
    echo "⬆️  Обновление claude-standards из проекта"
    has_changes=0

    # Only copy files that exist in both places (don't add project-specific commands)
    for f in "$COMMANDS_SRC"/*.md; do
      [ -f "$f" ] || continue
      local name="$(basename "$f")"
      if [ -f "$COMMANDS_DST/$name" ] && ! diff -q "$f" "$COMMANDS_DST/$name" >/dev/null 2>&1; then
        cp "$COMMANDS_DST/$name" "$COMMANDS_SRC/"
        echo "  ← commands/$name"
        has_changes=1
      fi
    done

    for f in "$MODULES_SRC"/*.md; do
      [ -f "$f" ] || continue
      local name="$(basename "$f")"
      if [ -f "$MODULES_DST/$name" ] && ! diff -q "$f" "$MODULES_DST/$name" >/dev/null 2>&1; then
        cp "$MODULES_DST/$name" "$MODULES_SRC/"
        echo "  ← modules/$name"
        has_changes=1
      fi
    done

    for f in "$PATTERNS_SRC"/*.md; do
      [ -f "$f" ] || continue
      local name="$(basename "$f")"
      if [ -f "$PATTERNS_DST/$name" ] && ! diff -q "$f" "$PATTERNS_DST/$name" >/dev/null 2>&1; then
        cp "$PATTERNS_DST/$name" "$PATTERNS_SRC/"
        echo "  ← patterns/$name"
        has_changes=1
      fi
    done

    if [ "$has_changes" -eq 0 ]; then
      echo "✅ Нет изменений для отправки"
    else
      echo "✅ Файлы обновлены. Не забудь закоммитить в claude-standards."
    fi
    ;;

  status)
    echo "🔍 Сравнение claude-standards ↔ проект ($PROJECT_DIR)"
    echo ""

    current_ver="$(cat "$VERSION_FILE" 2>/dev/null | tr -d '\n')"
    project_ver="$(cat "$PROJECT_VERSION_FILE" 2>/dev/null | tr -d '\n')"
    echo "   Standards: $current_ver"
    echo "   Проект:    ${project_ver:-не установлено}"
    echo ""

    all_match=true
    show_diff "$COMMANDS_SRC" "$COMMANDS_DST" "commands" || all_match=false
    show_diff "$MODULES_SRC" "$MODULES_DST" "modules" || all_match=false
    show_diff "$PATTERNS_SRC" "$PATTERNS_DST" "patterns" || all_match=false

    if $all_match; then
      echo "✅ Всё синхронизировано"
    fi
    ;;

  *)
    echo "Использование: $0 {install|pull|push|status} [project-dir]"
    exit 1
    ;;
esac
