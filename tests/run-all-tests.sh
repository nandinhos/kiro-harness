#!/usr/bin/env bash
# run-all-tests.sh — Suíte canônica do Kiro Harness.
# Executa todos os testes e agrega os exit codes. Exit 0 == tudo verde.
#
# Uso:
#   run-all-tests.sh            # modo normal (mostra cada suíte)
#   run-all-tests.sh --quiet    # só o resumo por suíte e o resultado final
#   run-all-tests.sh --verbose  # idem normal (reservado para expansão futura)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE="normal"
case "${1:-}" in
  --quiet) MODE="quiet" ;;
  --verbose) MODE="verbose" ;;
  "") : ;;
  *) echo "Opção desconhecida: $1" >&2; exit 2 ;;
esac

SUITES=(
  "test-structure.sh"
  "test-schema.sh"
  "test-detect-env.sh"
  "test-agents-integrity.sh"
  "test-hook-adapters.sh"
  "test-safety-gate.sh"
  "test-pre-push-gate.sh"
  "test-shellcheck.sh"
  "test-meta.sh"
)

failed=0
for s in "${SUITES[@]}"; do
  if [[ "$MODE" == "quiet" ]]; then
    out="$(bash "$HERE/$s" 2>&1)"; rc=$?
    printf '%-28s %s\n' "$s" "$(printf '%s' "$out" | grep -E '^Total:' | tail -1)"
  else
    printf '\n\033[1m######## %s ########\033[0m\n' "$s"
    bash "$HERE/$s"; rc=$?
  fi
  if [[ $rc -ne 0 ]]; then
    failed=$((failed + 1))
    printf '\033[31m>>> %s FALHOU (exit %d)\033[0m\n' "$s" "$rc"
  fi
done

printf '\n\033[1m================ RESULTADO FINAL ================\033[0m\n'
if [[ $failed -eq 0 ]]; then
  printf '\033[32m✅ TODAS AS SUÍTES PASSARAM\033[0m\n'
  exit 0
else
  printf '\033[31m❌ %d SUÍTE(S) FALHARAM\033[0m\n' "$failed"
  exit 1
fi
