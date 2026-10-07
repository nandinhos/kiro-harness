# ADR 004 — Mandatory CI Governance & Pre-Push Safety Gate

**Status**: Aceito
**Data**: 2026-10-07

## Contexto

Pushes com a suíte vermelha quebram a esteira de CI e o trabalho de todos. Checagens
parciais (um linter, um subconjunto de testes) não garantem integridade.

## Decisão

**Zero-Tolerance Pipeline Red**: em repositórios com CI ativa
(`.github/workflows/` ou `.gitlab-ci.yml`), `git push` é proibido sem um
**Flight Certificate** válido para o commit HEAD exato.

### Mecanismo de 3 camadas

1. **Flight Certificate** (`.kiro/.ceh/last-ci-run.json`): assinado por
   `scripts/test-runner.sh`, ancorado em `git rev-parse HEAD`.
   ```json
   { "commit_hash": "<hash>", "status": "PASS", "exit_code": 0 }
   ```
2. **Pre-Push Gate** (`scripts/pre-push-gate.sh`, acionado pelo hook
   `pre-push-ci-gate`): intercepta `git push` e aplica:
   - DENY se não há certificado;
   - DENY se `status != PASS` ou `exit_code != 0`;
   - DENY se o HEAD divergiu do commit testado;
   - ALLOW apenas quando o hash bate com um certificado verde.
3. **Prevenção de "freezing tests"**: a skill `clearer-review` sinaliza novas
   entradas em enums/seeders que quebrariam asserções de contagem cegas.

## Consequências

- Push só com suíte verde comprovada no commit exato.
- Fail-safe: ausência de `jq`/git não bloqueia (evita travar o fluxo por falha de infra).
- Validado por `tests/test-pre-push-gate.sh` em sandbox isolado.
