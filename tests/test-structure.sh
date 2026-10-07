#!/usr/bin/env bash
# test-structure.sh — Verifica a presença dos artefatos estruturais do harness.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/lib/assert.sh"

tests_begin "Estrutura: Steering Files"
for f in 00-clearer-protocol 01-safety-gate 02-evidence-semantics 03-risk-dial 04-ponytail-mode 05-coding-standards; do
  assert_file "steering/$f.md" "$ROOT/.kiro/steering/$f.md"
done

tests_begin "Estrutura: Skills (10)"
for s in clearer clearer-feature clearer-bugfix clearer-refactor clearer-review clearer-audit clearer-adhd clearer-test clearer-map learned-lesson; do
  assert_file "skills/$s/SKILL.md" "$ROOT/.kiro/skills/$s/SKILL.md"
done

tests_begin "Estrutura: Agents (6)"
for a in investigator architect implementer test-engineer reviewer evidence-auditor; do
  assert_file "agents/$a.json" "$ROOT/.kiro/agents/$a.json"
  assert_file "agents/prompts/$a.md" "$ROOT/.kiro/agents/prompts/$a.md"
done

tests_begin "Estrutura: Hooks"
for h in safety-gate pre-push-ci-gate session-start; do
  assert_file "hooks/$h.json" "$ROOT/.kiro/hooks/$h.json"
done

tests_begin "Estrutura: Scripts"
for sc in detect-env safety-gate pre-push-gate test-runner setup-branches; do
  assert_file "scripts/$sc.sh" "$ROOT/scripts/$sc.sh"
done
for sc in safety-gate-hook pre-push-hook session-start-hook; do
  assert_file "scripts/hooks/$sc.sh" "$ROOT/scripts/hooks/$sc.sh"
done

tests_begin "Estrutura: Instalador, CI e ADRs"
assert_file "install.sh" "$ROOT/install.sh"
assert_file ".github/workflows/ci.yml" "$ROOT/.github/workflows/ci.yml"
for adr in 003-system-one-epistemology 004-ci-governance-pre-push-gate 005-native-first-adaptation; do
  assert_file "docs/adr/$adr.md" "$ROOT/docs/adr/$adr.md"
done

tests_summary
