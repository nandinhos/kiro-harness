#!/usr/bin/env bash
# run-all-tests.sh — Suíte canônica do Kiro Harness.
# Executa todos os testes e agrega os exit codes. Exit 0 == tudo verde.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SUITES=(
  "test-structure.sh"
  "test-schema.sh"
  "test-detect-env.sh"
  "test-agents-integrity.sh"
  "test-hook-adapters.sh"
  "test-safety-gate.sh"
  "test-pre-push-gate.sh"
)

failed=0
for s in "${SUITES[@]}"; do
  printf '\n\033[1m######## %s ########\033[0m\n' "$s"
  bash "$HERE/$s"
  rc=$?
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
