#!/usr/bin/env bash
# test-meta.sh — Meta-testes: provam que a suíte DETECTA falhas reais (anti-falso-verde).
# Zero Fake Pass: um teste verde só tem valor se seria vermelho quando o código quebra.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib/assert.sh
source "$HERE/lib/assert.sh"

tests_begin "Meta: a lib de asserção reporta falha corretamente"
# Executa um assert que DEVE falhar, em subshell isolado, e confirma o contador.
fail_detected="$(
  bash -c '
    source "'"$HERE"'/lib/assert.sh"
    assert_eq "proposital" "esperado" "diferente" >/dev/null 2>&1
    echo "$TESTS_FAIL"
  '
)"
assert_eq "assert_eq divergente incrementa TESTS_FAIL" "1" "$fail_detected"

fail_exit="$(
  bash -c '
    source "'"$HERE"'/lib/assert.sh"
    assert_eq "x" "a" "b" >/dev/null 2>&1
    tests_summary >/dev/null 2>&1
    echo $?
  '
)"
assert_eq "tests_summary retorna !=0 com falha" "1" "$fail_exit"

tests_begin "Meta: gate com bug é DETECTADO pela lógica de teste (mutação)"
# Cria um safety-gate MUTANTE que sempre devolve ALLOW, e confirma que a
# verificação adversarial o reprova (um gate quebrado NÃO passaria no teste).
sb="$(mktemp -d)"; trap 'rm -rf "$sb"' EXIT
cat > "$sb/mutant-gate.sh" <<'MUT'
#!/usr/bin/env bash
# Gate mutante: sempre permite (bug proposital).
echo "ALLOW"; exit 0
MUT
chmod +x "$sb/mutant-gate.sh"

# O teste adversarial espera DENY (exit 20) para `rm -rf /`. O mutante dá ALLOW (0).
mv_out="$(printf 'rm -rf /\n' | "$sb/mutant-gate.sh" 2>/dev/null)"; mv_rc=$?
mutant_verdict="${mv_out}|${mv_rc}"
# Confirmamos que o mutante NÃO satisfaz o critério esperado (DENY|20).
if [[ "$mutant_verdict" == "DENY|20" ]]; then
  _fail "mutante deveria divergir do esperado, mas coincidiu"
else
  _pass "gate mutante (sempre ALLOW) é reprovado pelo critério DENY|20"
fi

tests_begin "Meta: o gate REAL satisfaz o critério que reprova o mutante"
rv_out="$(printf 'rm -rf /\n' | "$ROOT/scripts/safety-gate.sh" 2>/dev/null)"; rv_rc=$?
assert_eq "gate real bloqueia rm -rf / (DENY|20)" "DENY|20" "${rv_out}|${rv_rc}"

tests_summary
