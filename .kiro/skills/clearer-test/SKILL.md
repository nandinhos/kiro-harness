---
name: clearer-test
description: >-
  Execução e verificação determinística de testes. Identifica o comando canônico da CI,
  executa a suíte completa, captura evidências brutas e reporta sem mascaramento de falhas.
---

# CLEARER Test — Execução e Verificação de Testes

Execução determinística de testes com captura de evidências completas. Zero fake pass.

---

## Princípios

- **Exit code 0 = PASS**. Qualquer outro valor = FAIL a ser reportado sem mascara.
- **Suíte canônica completa** — nunca filtros parciais que omitam testes.
- **Output bruto capturado** — sem interpretação criativa dos resultados.
- **Sem "deve estar passando"** — ou passou e temos evidência, ou não passou.

---

## Fluxo de Execução

### 1. Descoberta do Comando Canônico

Identifique o comando de teste correto para o projeto:

```bash
# PHP/Laravel
vendor/bin/pest --coverage
php artisan test

# Node/TypeScript
npm test
npx vitest run
npx playwright test

# Python
pytest
python -m pytest -v

# Verificar CI para o comando exato
cat .github/workflows/*.yml | grep -A5 "run:"
```

### 2. Identificação do Runtime

- **Host nativo**: Executar diretamente se dependências estiverem disponíveis
- **Docker/Compose**: Executar via `docker compose exec app [comando]`
- **CI**: O comando do pipeline é a fonte da verdade

### 3. Execução e Captura

Execute o comando e capture:
- Exit code completo
- Output de sucesso/falha por teste
- Contagem: N passed, M failed, K skipped
- Tempo total de execução

### 4. Análise dos Resultados

```markdown
**Suíte executada**: [comando completo]
**Exit code**: [0 | N]
**Resultado**: PASS | FAIL
**Contagem**: [N passed / M failed / K skipped]
**Falhas identificadas** (se houver):
  - [arquivo:linha]: [mensagem de erro]
  - [arquivo:linha]: [mensagem de erro]
```

---

## Classificação de Cenários

| Cenário | Ação |
|---|---|
| Todos passando | Reportar PASS com evidência |
| Falhas existentes (antes da tarefa) | Documentar como baseline — não são regressões |
| Novas falhas introduzidas | BLOQUEANTE — reportar e investigar |
| Suíte flaky | Documentar taxa de falha e investigar |
| Comando não encontrado | Reportar UNKNOWN — não assumir sucesso |

---

## Formato de Saída

```markdown
## Test Report — <YYYY-MM-DD HH:MM>

**Ambiente**: DEV | HML | PRD
**Comando**: [comando exato executado]
**Runtime**: host nativo | docker | CI
**Exit Code**: 0 | N

**Resultado**: PASS | FAIL
**Contagem**:
  - Passed: N
  - Failed: M
  - Skipped: K
  - Tempo: Xs

**Falhas** (se houver):
  - [arquivo:linha]: [mensagem completa]

**Evidência**: [output bruto relevante]
**Confiança**: HIGH — suíte completa executada
```

---

## Anti-Padrões Proibidos

- ❌ Executar apenas 1 arquivo de teste e reportar "suíte verde"
- ❌ Ignorar warnings que indicam falhas silenciosas
- ❌ Reportar "deve estar passando" sem executar
- ❌ Mascarar saída de erro com mensagem de sucesso
