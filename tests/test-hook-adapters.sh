#!/usr/bin/env bash
# test-hook-adapters.sh — Testa os adaptadores de hook pre-push e session-start.
# (O adaptador safety-gate já é coberto por test-safety-gate.sh.)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/lib/assert.sh"

export KIRO_WORKSPACE_ROOT="$ROOT"
PREPUSH="$ROOT/scripts/hooks/pre-push-hook.sh"
SESSION="$ROOT/scripts/hooks/session-start-hook.sh"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

tests_begin "pre-push-hook: comando não-push -> exit 0"
printf '{"tool_input":{"command":"git status"}}\n' > "$tmp/status.json"
"$PREPUSH" < "$tmp/status.json" >/dev/null 2>&1; assert_exit "git status -> exit 0" 0 "$?"

tests_begin "pre-push-hook: push bloqueado pelo gate -> exit 2 (sandbox com CI, sem cert)"
# Sandbox isolado: repo com CI ativa e SEM Flight Certificate => gate DENY => hook exit 2.
sb="$(mktemp -d)"
git -C "$sb" init -q; git -C "$sb" config user.email t@t.dev; git -C "$sb" config user.name t
mkdir -p "$sb/.github/workflows" "$sb/scripts"
cp "$ROOT/scripts/pre-push-gate.sh" "$sb/scripts/pre-push-gate.sh"
printf 'name: ci\n' > "$sb/.github/workflows/ci.yml"
git -C "$sb" add -A; git -C "$sb" commit -q -m seed
printf '{"tool_input":{"command":"git push origin main"}}\n' > "$tmp/push_sb.json"
KIRO_WORKSPACE_ROOT="$sb" "$PREPUSH" < "$tmp/push_sb.json" >/dev/null 2>&1
assert_exit "push sem cert em repo com CI -> exit 2" 2 "$?"
rm -rf "$sb"

tests_begin "pre-push-hook: payload sem comando -> exit 0 (fail-safe)"
printf '{"tool_input":{}}\n' > "$tmp/empty.json"
"$PREPUSH" < "$tmp/empty.json" >/dev/null 2>&1; assert_exit "payload vazio -> exit 0" 0 "$?"

tests_begin "session-start-hook: imprime ambiente, branch e política"
out="$("$SESSION" 2>/dev/null)"; rc=$?
assert_exit "session-start -> exit 0" 0 "$rc"
assert_contains "contém marcador do harness" "$out" "Kiro Harness"
assert_contains "contém ambiente detectado" "$out" "Ambiente detectado"
assert_contains "contém política" "$out" "Política vigente"

tests_begin "session-start-hook: nunca falha mesmo fora de git"
nogit="$(mktemp -d)"
( cd "$nogit" && KIRO_WORKSPACE_ROOT="$nogit" "$SESSION" >/dev/null 2>&1 ); assert_exit "fora de git -> exit 0" 0 "$?"
rm -rf "$nogit"

tests_summary
