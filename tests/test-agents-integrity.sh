#!/usr/bin/env bash
# test-agents-integrity.sh — Valida que agents resolvem seus prompts e resources.
# Além do schema (coberto em test-schema.sh), confirma que cada file:// aponta
# para um arquivo que existe no disco — evita claim de artefato inexistente.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib/assert.sh
source "$HERE/lib/assert.sh"

AGENTS_DIR="$ROOT/.kiro/agents"

# Converte uma referência file:// em caminho absoluto no disco.
# prompt usa "file://./x" relativo ao diretório do agente;
# resources usam "file://.kiro/..." relativo à raiz do workspace.
resolve_ref() {
  local ref="$1" path
  path="${ref#file://}"
  if [[ "$path" == ./* ]]; then
    printf '%s/%s' "$AGENTS_DIR" "${path#./}"
  else
    printf '%s/%s' "$ROOT" "$path"
  fi
}

tests_begin "agents: prompt file:// resolve para arquivo existente"
for f in "$AGENTS_DIR"/*.json; do
  agent="$(basename "$f" .json)"
  prompt="$(jq -r '.prompt // empty' "$f")"
  if [[ -n "$prompt" ]]; then
    assert_file "agent '$agent' prompt -> $(basename "$(resolve_ref "$prompt")")" "$(resolve_ref "$prompt")"
  fi
done

tests_begin "agents: cada resource file:// resolve para arquivo existente"
for f in "$AGENTS_DIR"/*.json; do
  agent="$(basename "$f" .json)"
  while IFS= read -r res; do
    [[ -z "$res" ]] && continue
    case "$res" in
      file://*) assert_file "agent '$agent' resource -> $(basename "$res")" "$(resolve_ref "$res")" ;;
      skill://*) : ;; # skill:// é resolvido pelo Kiro, não valida caminho aqui
    esac
  done < <(jq -r '.resources[]? // empty' "$f")
done

tests_begin "agents: tools declaradas são conhecidas"
for f in "$AGENTS_DIR"/*.json; do
  agent="$(basename "$f" .json)"
  while IFS= read -r tool; do
    [[ -z "$tool" ]] && continue
    assert_contains "agent '$agent' tool '$tool' conhecida" "read write shell web use_aws fs_read fs_write execute_bash *" "$tool"
  done < <(jq -r '.tools[]? // empty' "$f")
done

tests_summary
