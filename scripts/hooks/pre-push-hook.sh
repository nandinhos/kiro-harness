#!/usr/bin/env bash
# pre-push-hook.sh — Adaptador do Pre-Push CI Gate para o protocolo de hooks do Kiro.
#
# Lê o payload JSON do evento PreToolUse no STDIN. Se o comando for `git push`,
# delega a scripts/pre-push-gate.sh. Traduz:
#   - DENY  -> exit 2 (bloqueia; STDERR volta ao agente)
#   - ALLOW -> exit 0
#
# Fail-safe: erro de parsing/execução => ALLOW (exit 0).

set -uo pipefail

REPO_ROOT="${KIRO_WORKSPACE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
GATE="$REPO_ROOT/scripts/pre-push-gate.sh"

[[ -x "$GATE" ]] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

payload="$(cat)"
cmd="$(printf '%s' "$payload" | jq -r '
  .tool_input.command // .toolInput.command // .input.command // .command // empty
' 2>/dev/null)"

[[ -z "$cmd" ]] && exit 0

# Invocação única do gate (achado M2): stderr capturado, exit code preservado.
err_file="$(mktemp)"
trap 'rm -f "$err_file"' EXIT
"$GATE" "$cmd" >/dev/null 2>"$err_file"
rc=$?

if [[ "$rc" -eq 20 ]]; then
  cat "$err_file" >&2
  exit 2
fi
exit 0
