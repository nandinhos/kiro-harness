#!/usr/bin/env bash
# install.sh — Instalador do Kiro Harness (CEH para Kiro CLI).
#
# Copia steering, skills, agents, hooks e scripts para o destino escolhido.
# Idempotente: re-rodar atualiza os artefatos sem duplicar.
#
# Uso:
#   ./install.sh            # instala global em ~/.kiro
#   ./install.sh --project /caminho/do/projeto   # instala em um projeto
#
# Observação: os hooks de bloqueio (safety-gate, pre-push-ci-gate) são
# distribuídos com "enabled": false. Ative-os conscientemente após revisar.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="global"
DEST="$HOME/.kiro"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) MODE="project"; DEST="${2:?caminho do projeto requerido}/.kiro"; shift 2 ;;
    --global)  MODE="global";  DEST="$HOME/.kiro"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Opção desconhecida: $1" >&2; exit 1 ;;
  esac
done

echo "[install] Modo: $MODE -> $DEST"
mkdir -p "$DEST"/{steering,skills,agents,hooks}

cp -r "$SRC/.kiro/steering/." "$DEST/steering/"
cp -r "$SRC/.kiro/skills/."   "$DEST/skills/"
cp -r "$SRC/.kiro/agents/."   "$DEST/agents/"
cp -r "$SRC/.kiro/hooks/."    "$DEST/hooks/"

# Scripts: ficam no diretório pai do .kiro para que ${KIRO_WORKSPACE_ROOT}/scripts resolva.
PARENT="$(dirname "$DEST")"
mkdir -p "$PARENT/scripts/hooks"
cp -r "$SRC/scripts/." "$PARENT/scripts/"
chmod +x "$PARENT"/scripts/*.sh "$PARENT"/scripts/hooks/*.sh 2>/dev/null || true

echo "[install] ✅ Instalado."
echo "[install] Steering: $(ls "$DEST/steering" | wc -l) arquivos"
echo "[install] Skills:   $(ls "$DEST/skills" | wc -l) skills"
echo "[install] Agents:   $(ls "$DEST/agents"/*.json 2>/dev/null | wc -l) agentes"
echo "[install] Hooks:    $(ls "$DEST/hooks"/*.json 2>/dev/null | wc -l) (verifique 'enabled' antes de ativar os de bloqueio)"
