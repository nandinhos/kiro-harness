#!/usr/bin/env bash
# setup-branches.sh — Configura a topologia de branches canônica do harness.
#
# Modo Clássico (padrão):   dev -> main
# Modo Enterprise:          dev -> staging -> main
#
# Uso:
#   ./setup-branches.sh --classic
#   ./setup-branches.sh --enterprise
#
# Cria as branches ausentes a partir da branch atual. Não força nada destrutivo.

set -euo pipefail

MODE="classic"
case "${1:-}" in
  --enterprise) MODE="enterprise" ;;
  --classic|"") MODE="classic" ;;
  -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "Opção desconhecida: $1" >&2; exit 1 ;;
esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Não é um repo git." >&2; exit 1; }

ensure_branch() {
  local b="$1"
  if git show-ref --verify --quiet "refs/heads/$b"; then
    echo "  = branch '$b' já existe"
  else
    git branch "$b" && echo "  + branch '$b' criada"
  fi
}

echo "[setup-branches] Topologia: $MODE"
case "$MODE" in
  classic)
    ensure_branch dev
    ensure_branch main
    echo "  Fluxo: dev (ALLOW) -> main (DENY destrutivos)"
    ;;
  enterprise)
    ensure_branch dev
    ensure_branch staging
    ensure_branch main
    echo "  Fluxo: dev (ALLOW) -> staging (ASK 2x) -> main (DENY destrutivos)"
    ;;
esac
echo "[setup-branches] ✅ Concluído."
