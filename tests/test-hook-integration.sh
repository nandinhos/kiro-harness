#!/usr/bin/env bash
# test-hook-integration.sh — Valida o adaptador safety-gate contra payloads reais
# do Kiro (fixtures), cobrindo variações de schema do evento PreToolUse.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib/assert.sh
source "$HERE/lib/assert.sh"

export KIRO_WORKSPACE_ROOT="$ROOT"
HOOK="$ROOT/scripts/hooks/safety-gate-hook.sh"
FIX="$HERE/fixtures"

# run_hook <APP_ENV> <fixture> -> exit code do hook
run_hook() { APP_ENV="$1" "$HOOK" < "$FIX/$2" >/dev/null 2>&1; echo $?; }

tests_begin "Integração: extração de comando por variação de schema"
# snake_case tool_input.command — DROP em PRD => bloqueia (exit 2)
assert_exit "payload snake_case (DROP/PRD) -> exit 2" 2 "$(run_hook production payload-snake-case.json)"
# camelCase toolInput.command — rm -rf / catastrófico => exit 2 em qualquer env
assert_exit "payload camelCase (rm -rf /) -> exit 2" 2 "$(run_hook dev payload-camel-case.json)"
# flat command — force push em HML => ask (exit 0)
assert_exit "payload flat (force push/HML) -> exit 0+ask" 0 "$(run_hook staging payload-flat.json)"
# benigno => exit 0
assert_exit "payload benigno -> exit 0" 0 "$(run_hook production payload-benign.json)"

tests_begin "Integração: payload flat em PRD emite ask JSON correto"
out="$(APP_ENV=staging "$HOOK" < "$FIX/payload-flat.json" 2>/dev/null)"
assert_contains "ask contém permissionDecision" "$out" '"permissionDecision":"ask"'

tests_begin "Integração: JSON malformado não quebra o hook (fail-safe)"
printf 'isto não é json {{{\n' > /tmp/kh_bad.json
"$HOOK" < /tmp/kh_bad.json >/dev/null 2>&1; assert_exit "payload inválido -> exit 0" 0 "$?"
rm -f /tmp/kh_bad.json

tests_summary
