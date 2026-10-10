#!/usr/bin/env bash
# assert.sh — Mini-biblioteca de asserção para a suíte do Kiro Harness.
# Determinística, zero dependências externas além de coreutils.
#
# Expõe: assert_eq, assert_exit, assert_contains, assert_file, assert_json
# e as funções de sumário: tests_begin / tests_summary.
# Variáveis de contagem exportadas: TESTS_RUN, TESTS_PASS, TESTS_FAIL.

TESTS_RUN=0
TESTS_PASS=0
TESTS_FAIL=0

_pass() { TESTS_RUN=$((TESTS_RUN + 1)); TESTS_PASS=$((TESTS_PASS + 1)); printf '  \033[32mPASS\033[0m %s\n' "$1"; }
_fail() { TESTS_RUN=$((TESTS_RUN + 1)); TESTS_FAIL=$((TESTS_FAIL + 1)); printf '  \033[31mFAIL\033[0m %s\n' "$1"; }

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then _pass "$label"; else
    _fail "$label (esperado='$expected' obtido='$actual')"; fi
}

assert_exit() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then _pass "$label"; else
    _fail "$label (exit esperado=$expected obtido=$actual)"; fi
}

assert_contains() {
  local label="$1" haystack="$2" needle="$3"
  if [[ "$haystack" == *"$needle"* ]]; then _pass "$label"; else
    _fail "$label (não contém '$needle')"; fi
}

assert_file() {
  local label="$1" path="$2"
  if [[ -f "$path" ]]; then _pass "$label"; else _fail "$label (arquivo ausente: $path)"; fi
}

assert_json() {
  local label="$1" path="$2"
  if jq empty "$path" >/dev/null 2>&1; then _pass "$label"; else
    _fail "$label (JSON inválido: $path)"; fi
}

tests_begin() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

tests_summary() {
  printf '\nTotal: %d | Pass: %d | Fail: %d\n' "$TESTS_RUN" "$TESTS_PASS" "$TESTS_FAIL"
  [[ "$TESTS_FAIL" -eq 0 ]]
}
