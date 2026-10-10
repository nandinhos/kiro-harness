#!/usr/bin/env bash
# safety-gate-hook.sh — Adaptador do Safety Gate para o protocolo de hooks do Kiro.
#
# Lê o payload JSON do evento PreToolUse no STDIN, extrai o comando shell candidato
# e delega a decisão a scripts/safety-gate.sh. Traduz o veredicto para o contrato
# de exit codes do Kiro:
#   - DENY  -> exit 2  (bloqueia a execução; STDERR volta ao agente)
#   - ASK   -> exit 0 + JSON permissionDecision=ask (usuário confirma)
#   - ALLOW -> exit 0  (silencioso)
#
# Fail-safe: qualquer erro de parsing/execução resulta em ALLOW (exit 0).

set -uo pipefail

REPO_ROOT="${KIRO_WORKSPACE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
GATE="$REPO_ROOT/scripts/safety-gate.sh"

[[ -x "$GATE" ]] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

payload="$(cat)"
cmd="$(printf '%s' "$payload" | jq -r '
  .tool_input.command // .toolInput.command // .input.command // .command // empty
' 2>/dev/null)"

[[ -z "$cmd" ]] && exit 0

# Invocação única do gate: stdout (veredicto textual) é descartado — o que importa
# é o exit code; stderr é capturado em arquivo; exit code preservado (achado M2).
err_file="$(mktemp)"
trap 'rm -f "$err_file"' EXIT
printf '%s' "$cmd" | "$GATE" >/dev/null 2>"$err_file"
rc=$?
reason="$(cat "$err_file")"

case "$rc" in
  20)
    printf '%s\n' "$reason" >&2
    exit 2
    ;;
  10)
    clean_reason="$(printf '%s' "$reason" | tr '\n' ' ' | sed 's/"/'"'"'/g')"
    printf '{"hookSpecificOutput":{"permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$clean_reason"
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
