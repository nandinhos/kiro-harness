#!/usr/bin/env bash
# session-start-hook.sh — Injeta contexto de ambiente no início da sessão.
#
# Equivalente ao `ceh-env` do CEH base. Detecta ambiente, branch e política,
# e imprime no STDOUT (o Kiro adiciona ao contexto em SessionStart).
#
# Exit code: sempre 0.

set -uo pipefail

REPO_ROOT="${KIRO_WORKSPACE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
DETECT="$REPO_ROOT/scripts/detect-env.sh"

env="UNKNOWN"
[[ -x "$DETECT" ]] && env="$("$DETECT" 2>/dev/null || echo UNKNOWN)"
branch="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"

case "$env" in
  PRODUCAO)    policy="🔴 DENY — ações destrutivas FORA DE COGITAÇÃO" ;;
  HOMOLOGACAO) policy="🟡 ASK — confirmação obrigatória em 2 alertas" ;;
  DEV)         policy="🟢 ALLOW — liberdade com salvaguarda local" ;;
  *)           policy="⚪ UNKNOWN — tratado como DEV com cautela" ;;
esac

cat <<CTX
[Kiro Harness — Safety Gate ativo]
Ambiente detectado: $env (branch: $branch)
Política vigente: $policy
CTX
