#!/usr/bin/env bash
# pre-push-gate.sh — Zero-Tolerance Pipeline Red (ADR 004).
#
# Intercepta `git push`. Em repositórios com CI ativa (.github/workflows ou
# .gitlab-ci.yml), exige um Flight Certificate válido antes de permitir o push:
#   - certificado existe
#   - status == PASS e exit_code == 0
#   - commit_hash == git rev-parse HEAD (código não mutou após os testes)
#
# Uso: pre-push-gate.sh "<comando git candidato>"
#
# Exit code:
#   0  -> ALLOW (não é push, repo sem CI, ou certificado válido)
#   20 -> DENY  (push sem certificado válido)
#
# Fail-safe: ausência de git/jq ou erro de parsing NÃO bloqueia (exit 0).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERT_FILE="$REPO_ROOT/.kiro/.ceh/last-ci-run.json"

is_push() { [[ "$1" =~ git[[:space:]]+(.*[[:space:]])?push([[:space:]]|$) ]]; }

has_ci() {
  [[ -d "$REPO_ROOT/.github/workflows" ]] && return 0
  [[ -f "$REPO_ROOT/.gitlab-ci.yml" ]] && return 0
  return 1
}

deny() {
  echo "DENY"
  echo "[PRE-PUSH GATE] 🛑 $1" >&2
  exit 20
}

main() {
  local cmd="${1:-}"
  is_push "$cmd" || { echo "ALLOW"; exit 0; }
  has_ci || { echo "ALLOW"; exit 0; }

  command -v jq >/dev/null 2>&1 || { echo "ALLOW"; exit 0; }
  [[ -f "$CERT_FILE" ]] || deny "Nenhum Flight Certificate. Rode scripts/test-runner.sh com suíte 100% verde antes do push."

  local status exit_code cert_hash head_hash
  status="$(jq -r '.status // empty' "$CERT_FILE" 2>/dev/null)"
  exit_code="$(jq -r '.exit_code // empty' "$CERT_FILE" 2>/dev/null)"
  cert_hash="$(jq -r '.commit_hash // empty' "$CERT_FILE" 2>/dev/null)"
  head_hash="$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo 'UNKNOWN')"

  [[ "$status" == "PASS" ]] || deny "Último run da suíte foi '$status' (!= PASS)."
  [[ "$exit_code" == "0" ]] || deny "Exit code do último run foi '$exit_code' (!= 0)."
  [[ "$cert_hash" == "$head_hash" ]] || deny "HEAD ($head_hash) divergiu do commit testado ($cert_hash). Re-execute a suíte."

  echo "ALLOW"
  echo "[PRE-PUSH GATE] ✅ Flight Certificate válido para ${head_hash:0:12}." >&2
  exit 0
}

main "$@"
