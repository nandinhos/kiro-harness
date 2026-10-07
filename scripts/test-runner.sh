#!/usr/bin/env bash
# test-runner.sh — Executor canônico da suíte + emissor do Flight Certificate.
#
# Roda a suíte de testes do harness e, ao final, assina um Flight Certificate
# (.kiro/.ceh/last-ci-run.json) ancorado ao hash do commit HEAD. O certificado
# é a prova consumida pelo Pre-Push CI Gate.
#
# Exit code: propaga o exit code da suíte (0 = verde).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERT_DIR="$REPO_ROOT/.kiro/.ceh"
CERT_FILE="$CERT_DIR/last-ci-run.json"
SUITE="$REPO_ROOT/tests/run-all-tests.sh"

main() {
  if [[ ! -x "$SUITE" ]]; then
    echo "[test-runner] Suíte não encontrada ou não executável: $SUITE" >&2
    return 1
  fi

  echo "[test-runner] Executando suíte canônica..."
  "$SUITE"
  local status=$?

  mkdir -p "$CERT_DIR"
  local commit_hash timestamp verdict
  commit_hash="$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo 'UNKNOWN')"
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ $status -eq 0 ]]; then verdict="PASS"; else verdict="FAIL"; fi

  cat >"$CERT_FILE" <<JSON
{
  "commit_hash": "$commit_hash",
  "timestamp": "$timestamp",
  "command": "tests/run-all-tests.sh",
  "status": "$verdict",
  "exit_code": $status
}
JSON

  echo "[test-runner] Flight Certificate assinado: $verdict (exit $status) @ ${commit_hash:0:12}"
  return $status
}

main "$@"
