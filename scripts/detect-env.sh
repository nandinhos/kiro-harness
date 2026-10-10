#!/usr/bin/env bash
# detect-env.sh — Detector de ambiente do Kiro Harness (CEH).
#
# Fonte da verdade para o Safety Gate. Classifica o ambiente de execução em
# DEV, HOMOLOGACAO ou PRODUCAO com base em evidência OBSERVED (branch git + APP_ENV).
#
# Saída (stdout): uma linha com o ambiente detectado — DEV | HOMOLOGACAO | PRODUCAO | UNKNOWN
# Exit code: sempre 0 (detecção nunca bloqueia; a política é decidida por quem consome).
#
# Precedência: APP_ENV explícito vence a branch git. Sem evidência suficiente => UNKNOWN.

set -uo pipefail

detect_from_app_env() {
  local app_env="${APP_ENV:-}"
  [[ -z "$app_env" ]] && return 1
  case "${app_env,,}" in
    local | test | testing | dev | development) echo "DEV" ;;
    staging | homolog | homologacao) echo "HOMOLOGACAO" ;;
    prod | production | producao) echo "PRODUCAO" ;;
    *) return 1 ;;
  esac
  return 0
}

detect_from_branch() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return 1
  [[ -z "$branch" || "$branch" == "HEAD" ]] && return 1
  case "$branch" in
    main | master) echo "PRODUCAO" ;;
    staging | homolog | homologacao) echo "HOMOLOGACAO" ;;
    dev | develop | development | dev/*) echo "DEV" ;;
    *) echo "DEV" ;; # feature branches tratadas como DEV (liberdade com salvaguarda)
  esac
  return 0
}

main() {
  if detect_from_app_env; then
    return 0
  fi
  if detect_from_branch; then
    return 0
  fi
  echo "UNKNOWN"
}

main "$@"
