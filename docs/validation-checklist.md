# ✅ Checklist de Validação Manual

A suíte automatizada cobre a lógica dos scripts e o contrato dos adaptadores de hook.
Esta checklist cobre o que só a validação humana no Kiro real confirma: a ativação
efetiva dos hooks e o comportamento end-to-end.

## Pré-requisitos

- [ ] `jq` instalado (`command -v jq`)
- [ ] Suíte verde localmente: `./tests/run-all-tests.sh` → exit 0
- [ ] Harness instalado: `./install.sh --project <projeto>` ou global

## 1. Hooks de bloqueio (ativar conscientemente)

Os hooks `safety-gate` e `pre-push-ci-gate` são distribuídos com `"enabled": false`.
Para validar, ative-os temporariamente (`"enabled": true`) e:

- [ ] **Safety Gate em PRD**: em uma branch `main`/`master`, peça ao agente um comando
      destrutivo (ex.: `rm -rf build`). Esperado: o hook intercepta e bloqueia.
- [ ] **Safety Gate em DEV**: na branch `dev`, o mesmo comando é permitido (com aviso).
- [ ] **Catastrófico universal**: `rm -rf /` é bloqueado em qualquer branch.
- [ ] **Falso positivo controlado**: `echo "rm -rf /"` (string) NÃO é bloqueado.

## 2. Pre-Push CI Gate

- [ ] Com a suíte vermelha (ou sem Flight Certificate), tentar `git push` → bloqueado.
- [ ] Após `./scripts/test-runner.sh` com suíte verde → push permitido.
- [ ] Após alterar um arquivo (mudando o HEAD) sem re-testar → push bloqueado (hash divergente).

## 3. Session Start

- [ ] Ao iniciar uma sessão no Kiro com o harness ativo, o contexto deve conter a linha
      `Ambiente detectado: <ENV> (branch: <branch>)`.

## 4. Subagentes

- [ ] `/agent` lista os 6 agentes (investigator, architect, implementer, test-engineer,
      reviewer, evidence-auditor).
- [ ] Cada agente carrega seu prompt e steering declarados em `resources`.

## 5. Skills

- [ ] `/clearer` e as demais skills são descobertas e ativáveis.

> Registre o resultado desta checklist antes de qualquer promoção `dev → main`.
