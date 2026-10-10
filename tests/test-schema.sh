#!/usr/bin/env bash
# test-schema.sh — Valida o schema de skills (front-matter), agents (JSON) e hooks (JSON v1).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib/assert.sh
source "$HERE/lib/assert.sh"

tests_begin "Schema: Skills front-matter (name + description)"
for d in "$ROOT"/.kiro/skills/*/; do
  skill="$(basename "$d")"
  fm="$(sed -n '/^---$/,/^---$/p' "$d/SKILL.md")"
  name="$(printf '%s' "$fm" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//')"
  has_desc="$(printf '%s' "$fm" | grep -cE '^description:')"
  assert_eq "skill '$skill' name == pasta" "$skill" "$name"
  assert_eq "skill '$skill' tem description" "1" "$has_desc"
done

tests_begin "Schema: Agents JSON válido + campos mínimos"
for f in "$ROOT"/.kiro/agents/*.json; do
  agent="$(basename "$f" .json)"
  assert_json "agent '$agent' JSON válido" "$f"
  name="$(jq -r '.name // empty' "$f" 2>/dev/null)"
  prompt="$(jq -r '.prompt // empty' "$f" 2>/dev/null)"
  assert_eq "agent '$agent' name == arquivo" "$agent" "$name"
  assert_contains "agent '$agent' prompt é file://" "$prompt" "file://"
done

tests_begin "Schema: Hooks JSON v1 válido"
for f in "$ROOT"/.kiro/hooks/*.json; do
  hook="$(basename "$f" .json)"
  assert_json "hook '$hook' JSON válido" "$f"
  version="$(jq -r '.version // empty' "$f" 2>/dev/null)"
  trigger="$(jq -r '.hooks[0].trigger // empty' "$f" 2>/dev/null)"
  assert_eq "hook '$hook' version == v1" "v1" "$version"
  assert_contains "hook '$hook' trigger válido" "SessionStart Stop PreToolUse PostToolUse PreTaskExec PostTaskExec UserPromptSubmit PostFileCreate PostFileSave PostFileDelete Manual" "$trigger"
done

tests_begin "Schema: hooks de bloqueio distribuídos desativados (invariante de segurança)"
# Hooks que podem BLOQUEAR ações (PreToolUse com exit 2) devem ser distribuídos
# com enabled:false — ativação é decisão consciente do operador.
for hook in safety-gate pre-push-ci-gate; do
  enabled="$(jq -r '.hooks[0].enabled' "$ROOT/.kiro/hooks/$hook.json" 2>/dev/null)"
  assert_eq "hook bloqueante '$hook' distribuído com enabled:false" "false" "$enabled"
done
# Hook não-bloqueante (session-start) pode vir ativo.
sstart="$(jq -r '.hooks[0].enabled' "$ROOT/.kiro/hooks/session-start.json" 2>/dev/null)"
assert_eq "hook session-start ativo (não-bloqueante)" "true" "$sstart"

tests_summary
