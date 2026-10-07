#!/usr/bin/env bash
# test-safety-gate.sh — Testes adversariais do Safety Gate (núcleo + hook adaptador).
# Cada caso injeta um comando candidato e verifica o veredicto/exit code esperado.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/lib/assert.sh"

GATE="$ROOT/scripts/safety-gate.sh"
HOOK="$ROOT/scripts/hooks/safety-gate-hook.sh"
export KIRO_WORKSPACE_ROOT="$ROOT"

# gate_verdict <APP_ENV> <comando-em-arquivo> -> imprime veredicto, retorna exit code real
run_gate() { # $1=app_env  $2=file-with-command
  local out rc
  out="$(APP_ENV="$1" "$GATE" "$(cat "$2")" 2>/dev/null)"
  rc=$?
  printf '%s|%s' "$out" "$rc"
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Comandos candidatos gravados em arquivo (evita interpolação no próprio teste)
printf 'ls -la\n'                         > "$tmp/benign"
printf 'rm -rf build/\n'                  > "$tmp/rmbuild"
printf 'git push --force origin main\n'   > "$tmp/forcepush"
printf 'psql -c "DROP TABLE users"\n'     > "$tmp/droptable"
printf 'terraform destroy\n'              > "$tmp/tfdestroy"

tests_begin "Safety Gate: ambiente DEV (ALLOW destrutivo com salvaguarda)"
r="$(run_gate dev "$tmp/benign")";    assert_eq "ls -> ALLOW"         "ALLOW|0" "$r"
r="$(run_gate dev "$tmp/rmbuild")";   assert_eq "rm -rf build -> ALLOW" "ALLOW|0" "$r"
r="$(run_gate dev "$tmp/droptable")"; assert_eq "DROP em dev -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: ambiente HOMOLOGACAO (ASK)"
r="$(run_gate staging "$tmp/forcepush")"; assert_eq "force push -> ASK"  "ASK|10" "$r"
r="$(run_gate staging "$tmp/droptable")"; assert_eq "DROP -> ASK"        "ASK|10" "$r"
r="$(run_gate staging "$tmp/tfdestroy")"; assert_eq "tf destroy -> ASK"  "ASK|10" "$r"

tests_begin "Safety Gate: ambiente PRODUCAO (DENY)"
r="$(run_gate production "$tmp/forcepush")"; assert_eq "force push -> DENY" "DENY|20" "$r"
r="$(run_gate production "$tmp/droptable")"; assert_eq "DROP -> DENY"       "DENY|20" "$r"
r="$(run_gate production "$tmp/tfdestroy")"; assert_eq "tf destroy -> DENY" "DENY|20" "$r"
r="$(run_gate production "$tmp/benign")";    assert_eq "ls em prd -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: destruição catastrófica (DENY em QUALQUER ambiente)"
# Montado em runtime para não deixar o padrão literal no fonte do teste
printf 'rm -rf %s\n' "/" > "$tmp/catastrophic"
r="$(run_gate dev "$tmp/catastrophic")";        assert_eq "catastrófico curto em DEV -> DENY" "DENY|20" "$r"
printf 'sudo rm -rf %s\n' "/" > "$tmp/cat_sudo"
r="$(run_gate dev "$tmp/cat_sudo")";            assert_eq "evasão sudo -> DENY"        "DENY|20" "$r"
# C2: flags longas GNU não podem escapar (regressão)
printf 'rm --recursive --force %s\n' "/" > "$tmp/cat_long"
r="$(run_gate dev "$tmp/cat_long")";            assert_eq "flags longas em DEV -> DENY" "DENY|20" "$r"
r="$(run_gate production "$tmp/cat_long")";      assert_eq "flags longas em PRD -> DENY" "DENY|20" "$r"
printf 'rm -r -f %s\n' "/" > "$tmp/cat_split"
r="$(run_gate dev "$tmp/cat_split")";           assert_eq "flags separadas -> DENY"    "DENY|20" "$r"

tests_begin "Safety Gate: C1 — DELETE FROM com WHERE não escapa"
printf 'psql -c "DELETE FROM users WHERE id=1"\n' > "$tmp/del_where"
r="$(run_gate production "$tmp/del_where")";     assert_eq "DELETE WHERE em PRD -> DENY" "DENY|20" "$r"
printf 'psql -c "DELETE FROM logs"\n' > "$tmp/del_nowhere"
r="$(run_gate production "$tmp/del_nowhere")";   assert_eq "DELETE sem WHERE em PRD -> DENY" "DENY|20" "$r"
r="$(run_gate dev "$tmp/del_where")";            assert_eq "DELETE WHERE em DEV -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: C2 — rm recursivo+força longo (política por ambiente)"
printf 'rm --recursive --force node_modules\n' > "$tmp/rm_long_rel"
r="$(run_gate dev "$tmp/rm_long_rel")";          assert_eq "rm longo relativo em DEV -> ALLOW" "ALLOW|0" "$r"
r="$(run_gate production "$tmp/rm_long_rel")";    assert_eq "rm longo relativo em PRD -> DENY" "DENY|20" "$r"
printf 'rm -f arquivo.txt\n' > "$tmp/rm_force_only"
r="$(run_gate production "$tmp/rm_force_only")";  assert_eq "rm -f (sem -r) -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: hook adaptador (contrato de exit code do Kiro)"
# PRD DROP -> exit 2
printf '{"tool_input":{"command":"psql -c \\"DROP TABLE users\\""}}\n' > "$tmp/p_prd.json"
APP_ENV=production "$HOOK" < "$tmp/p_prd.json" >/dev/null 2>&1; assert_exit "hook PRD DROP -> exit 2" 2 "$?"
# HML force push -> exit 0 + ask
printf '{"tool_input":{"command":"git push --force origin staging"}}\n' > "$tmp/p_hml.json"
out="$(APP_ENV=staging "$HOOK" < "$tmp/p_hml.json" 2>/dev/null)"; rc=$?
assert_exit "hook HML -> exit 0" 0 "$rc"
assert_contains "hook HML -> permissionDecision ask" "$out" '"permissionDecision":"ask"'
# benign -> exit 0 silencioso
printf '{"tool_input":{"command":"ls -la"}}\n' > "$tmp/p_ok.json"
"$HOOK" < "$tmp/p_ok.json" >/dev/null 2>&1; assert_exit "hook benign -> exit 0" 0 "$?"

tests_begin "Safety Gate: H2 — leitores não disparam sobre conteúdo citado"
printf 'echo "DROP TABLE users"\n' > "$tmp/echo_drop"
r="$(run_gate production "$tmp/echo_drop")";     assert_eq "echo DROP em PRD -> ALLOW" "ALLOW|0" "$r"
printf 'grep "rm -rf /" script.sh\n' > "$tmp/grep_rm"
r="$(run_gate production "$tmp/grep_rm")";       assert_eq "grep rm -rf em PRD -> ALLOW" "ALLOW|0" "$r"
printf 'cat migrate:fresh.md\n' > "$tmp/cat_migrate"
r="$(run_gate production "$tmp/cat_migrate")";   assert_eq "cat migrate:fresh.md -> ALLOW" "ALLOW|0" "$r"
printf 'git log --oneline\n' > "$tmp/gitlog"
r="$(run_gate production "$tmp/gitlog")";        assert_eq "git log -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: H1 — migrate:* ancorado (sem falso positivo em nome de arquivo)"
printf 'php artisan migrate:fresh\n' > "$tmp/mig_real"
r="$(run_gate production "$tmp/mig_real")";      assert_eq "migrate:fresh real em PRD -> DENY" "DENY|20" "$r"
printf './migrate:fresh-helper.sh\n' > "$tmp/mig_file"
r="$(run_gate production "$tmp/mig_file")";      assert_eq "migrate:fresh-helper (arquivo) -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: M1 — catálogo ampliado (docker/find/truncate)"
printf 'docker system prune -af\n' > "$tmp/docker_prune"
r="$(run_gate production "$tmp/docker_prune")";  assert_eq "docker system prune em PRD -> DENY" "DENY|20" "$r"
r="$(run_gate dev "$tmp/docker_prune")";         assert_eq "docker system prune em DEV -> ALLOW" "ALLOW|0" "$r"
printf 'find . -name "*.log" -delete\n' > "$tmp/find_del"
r="$(run_gate production "$tmp/find_del")";      assert_eq "find -delete em PRD -> DENY" "DENY|20" "$r"
printf 'truncate -s 0 database.sql\n' > "$tmp/trunc"
r="$(run_gate production "$tmp/trunc")";         assert_eq "truncate -s 0 em PRD -> DENY" "DENY|20" "$r"
printf 'docker compose down --volumes\n' > "$tmp/compose_down"
r="$(run_gate production "$tmp/compose_down")";  assert_eq "compose down --volumes em PRD -> DENY" "DENY|20" "$r"

tests_begin "Safety Gate: C3 — evasão por chaining após leader (regressão de segurança)"
printf 'echo x && rm -rf %s\n' "/" > "$tmp/chain_and"
r="$(run_gate production "$tmp/chain_and")";     assert_eq "echo && rm -rf / -> DENY" "DENY|20" "$r"
printf 'echo x ; rm -rf %s\n' "/" > "$tmp/chain_semi"
r="$(run_gate dev "$tmp/chain_semi")";           assert_eq "echo ; rm -rf / em DEV -> DENY" "DENY|20" "$r"
printf 'echo x && psql -c "DROP TABLE users"\n' > "$tmp/chain_drop"
r="$(run_gate production "$tmp/chain_drop")";     assert_eq "echo && DROP em PRD -> DENY" "DENY|20" "$r"
printf 'grep foo file && git push --force origin main\n' > "$tmp/chain_push"
r="$(run_gate production "$tmp/chain_push")";     assert_eq "grep && force push em PRD -> DENY" "DENY|20" "$r"
printf 'cat README && docker system prune -af\n' > "$tmp/chain_docker"
r="$(run_gate staging "$tmp/chain_docker")";      assert_eq "cat && docker prune em HML -> ASK" "ASK|10" "$r"
# o caso benigno legítimo que o H2 protege permanece ALLOW
printf 'echo "rm -rf /"\n' > "$tmp/echo_string"
r="$(run_gate production "$tmp/echo_string")";    assert_eq "echo 'rm -rf /' (string) -> ALLOW" "ALLOW|0" "$r"
printf 'echo iniciando && npm run build\n' > "$tmp/chain_benign"
r="$(run_gate production "$tmp/chain_benign")";   assert_eq "echo && npm build -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: C3-bis — wrappers de execução e subshell não evadem"
printf 'bash -c "rm -rf %s"\n' "/" > "$tmp/wrap_bash"
r="$(run_gate production "$tmp/wrap_bash")";     assert_eq "bash -c rm -rf / -> DENY" "DENY|20" "$r"
printf 'sh -c "rm -rf %s"\n' "/" > "$tmp/wrap_sh"
r="$(run_gate dev "$tmp/wrap_sh")";              assert_eq "sh -c rm -rf / em DEV -> DENY" "DENY|20" "$r"
printf 'eval "rm -rf %s"\n' "/" > "$tmp/wrap_eval"
r="$(run_gate production "$tmp/wrap_eval")";      assert_eq "eval rm -rf / -> DENY" "DENY|20" "$r"
printf 'echo $(rm -rf %s)\n' "/" > "$tmp/wrap_subshell"
r="$(run_gate production "$tmp/wrap_subshell")";  assert_eq "subshell rm -rf / -> DENY" "DENY|20" "$r"
printf 'bash -c "psql -c \\"DROP TABLE users\\""\n' > "$tmp/wrap_drop"
r="$(run_gate production "$tmp/wrap_drop")";       assert_eq "bash -c DROP em PRD -> DENY" "DENY|20" "$r"

tests_begin "Safety Gate: fork bomb (DENY universal, resiliente à normalização)"
printf ':(){ :|:& };:\n' > "$tmp/forkbomb"
r="$(run_gate dev "$tmp/forkbomb")";             assert_eq "fork bomb em DEV -> DENY" "DENY|20" "$r"
r="$(run_gate production "$tmp/forkbomb")";        assert_eq "fork bomb em PRD -> DENY" "DENY|20" "$r"

tests_begin "Safety Gate: process substitution <(...) não evade (C3-ter)"
printf 'cat <(rm -rf %s)\n' "/" > "$tmp/psub_rm"
r="$(run_gate production "$tmp/psub_rm")";        assert_eq "cat <(rm -rf /) em PRD -> DENY" "DENY|20" "$r"
r="$(run_gate dev "$tmp/psub_rm")";               assert_eq "cat <(rm -rf /) em DEV -> DENY" "DENY|20" "$r"
printf 'grep x <(git reset --hard)\n' > "$tmp/psub_git"
r="$(run_gate production "$tmp/psub_git")";        assert_eq "grep <(git reset --hard) -> DENY" "DENY|20" "$r"
printf 'diff <(cat a) <(cat b)\n' > "$tmp/psub_benign"
r="$(run_gate production "$tmp/psub_benign")";     assert_eq "diff <(cat) <(cat) benigno -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: rm por caminho absoluto não evade (C3-quater)"
printf '/bin/rm -rf %s\n' "/" > "$tmp/absrm"
r="$(run_gate production "$tmp/absrm")";          assert_eq "/bin/rm -rf / em PRD -> DENY" "DENY|20" "$r"
r="$(run_gate dev "$tmp/absrm")";                 assert_eq "/bin/rm -rf / em DEV -> DENY" "DENY|20" "$r"
printf '/usr/bin/rm --recursive --force %s\n' "/" > "$tmp/absrm2"
r="$(run_gate dev "$tmp/absrm2")";                assert_eq "/usr/bin/rm --recursive --force / -> DENY" "DENY|20" "$r"
printf '/bin/rm -rf node_modules\n' > "$tmp/absrm_rel"
r="$(run_gate production "$tmp/absrm_rel")";       assert_eq "/bin/rm -rf relativo em PRD -> DENY" "DENY|20" "$r"
r="$(run_gate dev "$tmp/absrm_rel")";             assert_eq "/bin/rm -rf relativo em DEV -> ALLOW" "ALLOW|0" "$r"

tests_begin "Safety Gate: indireção de flag/arg via variável inline (C3-quinquies)"
printf 'R=rf; rm -$R %s\n' "/" > "$tmp/var_flag"
r="$(run_gate dev "$tmp/var_flag")";              assert_eq "R=rf; rm -\$R / em DEV -> DENY" "DENY|20" "$r"
printf 'R=rf; rm -${R} %s\n' "/" > "$tmp/var_braces"
r="$(run_gate dev "$tmp/var_braces")";            assert_eq "R=rf; rm -\${R} / -> DENY" "DENY|20" "$r"
printf 'X=/; rm -rf $X\n' > "$tmp/var_path"
r="$(run_gate dev "$tmp/var_path")";              assert_eq "X=/; rm -rf \$X -> DENY" "DENY|20" "$r"
# benigno: variável de ambiente não deve disparar
printf 'NODE_ENV=prod npm start\n' > "$tmp/var_benign"
r="$(run_gate production "$tmp/var_benign")";      assert_eq "NODE_ENV=prod npm start -> ALLOW" "ALLOW|0" "$r"

tests_summary
