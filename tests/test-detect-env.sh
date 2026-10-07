#!/usr/bin/env bash
# test-detect-env.sh — Testes unitários do detector de ambiente.
# Isola a branch git em repos temporários para determinismo (não depende do repo real).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/lib/assert.sh"

DETECT="$ROOT/scripts/detect-env.sh"

# Executa o detector dentro de um repo git com a branch indicada.
# $1 = nome da branch ; demais = env vars (ex: APP_ENV=...)
detect_in_branch() {
  local branch="$1"; shift
  local sb; sb="$(mktemp -d)"
  git -C "$sb" init -q
  git -C "$sb" config user.email t@t.dev
  git -C "$sb" config user.name tester
  git -C "$sb" commit -q --allow-empty -m seed
  git -C "$sb" branch -m "$branch" 2>/dev/null || git -C "$sb" checkout -q -b "$branch"
  ( cd "$sb" && env "$@" "$DETECT" )
  rm -rf "$sb"
}

tests_begin "detect-env: por branch git"
assert_eq "main -> PRODUCAO"       "PRODUCAO"    "$(detect_in_branch main)"
assert_eq "master -> PRODUCAO"     "PRODUCAO"    "$(detect_in_branch master)"
assert_eq "staging -> HOMOLOGACAO" "HOMOLOGACAO" "$(detect_in_branch staging)"
assert_eq "homolog -> HOMOLOGACAO" "HOMOLOGACAO" "$(detect_in_branch homolog)"
assert_eq "dev -> DEV"             "DEV"         "$(detect_in_branch dev)"
assert_eq "develop -> DEV"         "DEV"         "$(detect_in_branch develop)"
assert_eq "feature/x -> DEV"       "DEV"         "$(detect_in_branch feature/x)"
assert_eq "aleatoria -> DEV"       "DEV"         "$(detect_in_branch alguma-branch-qualquer)"

tests_begin "detect-env: APP_ENV tem precedência sobre a branch"
assert_eq "APP_ENV=production em branch dev -> PRODUCAO"  "PRODUCAO"    "$(detect_in_branch dev APP_ENV=production)"
assert_eq "APP_ENV=staging em branch main -> HOMOLOGACAO" "HOMOLOGACAO" "$(detect_in_branch main APP_ENV=staging)"
assert_eq "APP_ENV=local em branch main -> DEV"           "DEV"         "$(detect_in_branch main APP_ENV=local)"
assert_eq "APP_ENV=testing em branch main -> DEV"         "DEV"         "$(detect_in_branch main APP_ENV=testing)"

tests_begin "detect-env: APP_ENV desconhecido cai na branch"
assert_eq "APP_ENV=xpto em branch main -> PRODUCAO" "PRODUCAO" "$(detect_in_branch main APP_ENV=xpto)"

tests_begin "detect-env: fora de repo git e sem APP_ENV -> UNKNOWN"
nogit="$(mktemp -d)"
assert_eq "sem git -> UNKNOWN" "UNKNOWN" "$(cd "$nogit" && env -u APP_ENV "$DETECT")"
rm -rf "$nogit"

tests_summary
