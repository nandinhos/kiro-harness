#!/usr/bin/env bash
# test-shellcheck.sh — Lint estático dos scripts shell (tolerante).
# Se shellcheck não estiver instalado, o teste é PULADO (não falha) — a
# ferramenta é um reforço, não uma dependência dura do harness.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib/assert.sh
source "$HERE/lib/assert.sh"

tests_begin "ShellCheck: lint estático"

if ! command -v shellcheck >/dev/null 2>&1; then
  printf '  \033[33mSKIP\033[0m shellcheck não instalado — lint pulado\n'
  tests_summary
  exit 0
fi

cd "$ROOT" || { _fail "não foi possível entrar em $ROOT"; tests_summary; exit 1; }
mapfile -t scripts < <(find scripts tests -name '*.sh' -type f | sort)
for s in "${scripts[@]}"; do
  if shellcheck "$s" >/dev/null 2>&1; then
    _pass "lint $s"
  else
    _fail "lint $s"
    shellcheck "$s" 2>&1 | sed 's/^/      /'
  fi
done

tests_summary
