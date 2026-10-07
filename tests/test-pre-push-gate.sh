#!/usr/bin/env bash
# test-pre-push-gate.sh — Testa o Pre-Push CI Gate (Flight Certificate) em sandbox isolado.
# NÃO toca no repositório real: cria um repo git temporário com .github/workflows.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib/assert.sh
source "$HERE/lib/assert.sh"

GATE="$ROOT/scripts/pre-push-gate.sh"

sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT

# Monta um repo git mínimo com CI ativa
git -C "$sandbox" init -q
git -C "$sandbox" config user.email t@t.dev
git -C "$sandbox" config user.name tester
mkdir -p "$sandbox/.github/workflows" "$sandbox/.kiro/.ceh" "$sandbox/scripts"
cp "$GATE" "$sandbox/scripts/pre-push-gate.sh"
printf 'name: ci\n' > "$sandbox/.github/workflows/ci.yml"
echo "seed" > "$sandbox/README.md"
git -C "$sandbox" add -A
git -C "$sandbox" commit -qm "seed"

SBGATE="$sandbox/scripts/pre-push-gate.sh"
CERT="$sandbox/.kiro/.ceh/last-ci-run.json"
HEAD="$(git -C "$sandbox" rev-parse HEAD)"

run() { ( cd "$sandbox" && "$SBGATE" "$1" >/dev/null 2>&1; echo $? ); }

tests_begin "Pre-Push Gate: comando não-push sempre ALLOW"
assert_exit "git status -> allow" 0 "$(run 'git status')"

tests_begin "Pre-Push Gate: push sem certificado -> DENY"
assert_exit "push sem cert -> deny" 20 "$(run 'git push origin main')"

tests_begin "Pre-Push Gate: certificado FAIL -> DENY"
printf '{"commit_hash":"%s","status":"FAIL","exit_code":1}\n' "$HEAD" > "$CERT"
assert_exit "cert FAIL -> deny" 20 "$(run 'git push origin main')"

tests_begin "Pre-Push Gate: certificado de outro commit -> DENY"
printf '{"commit_hash":"deadbeef","status":"PASS","exit_code":0}\n' > "$CERT"
assert_exit "cert hash divergente -> deny" 20 "$(run 'git push origin main')"

tests_begin "Pre-Push Gate: certificado válido para HEAD -> ALLOW"
printf '{"commit_hash":"%s","status":"PASS","exit_code":0}\n' "$HEAD" > "$CERT"
assert_exit "cert válido -> allow" 0 "$(run 'git push origin main')"

tests_summary
