---
name: clearer-bugfix
description: >-
  Systematic Debugging v3 com 5 gates bloqueantes (RFC 2119). Matriz de Hipóteses
  falsificáveis, Toolbox de isolamento (bisect/binary search/tracing), causa raiz por
  5 Porques + Ishikawa, Prevenção em 3 Níveis, lição aprendida embutida no report e
  integração com learned-lesson para persistência permanente.
version: 3.0.0
---

# CLEARER Systematic Debugging Engine v3.0
### Workflow Determinístico de Depuração em 5 Gates Bloqueantes

> **Princípio Fundamental (RFC 2119):**
> Nunca chute a causa. Prove com artefato.
> Linguagem normativa: **DEVE**, **NÃO DEVE**, **BLOQUEADO SE**.
> Sem teste vermelho prévio e sem evidência `OBSERVED` = **SEM AVANÇO**.

---

## Quando Usar

Ative este workflow diante de sinais de defeito comprovável:

`bug` · `erro` · `falha` · `não funciona` · `quebrou` · `regressão` ·
`comportamento inesperado` · `flaky` · `intermitente` · `exception` · `stack trace`

> Para implementar funcionalidade nova use `/clearer-feature`. Para limpeza sem mudança
> de comportamento use `/clearer-refactor`. Este workflow é **exclusivo para defeitos**.

---

## Visão Geral dos 5 Gates

```
GATE 0: TRIAGE ──► GATE 1: REPRODUCE (Red) ──► GATE 2: ISOLATE (Hipóteses)
                                                          │
                                                          ▼
                              GATE 3: ROOT CAUSE ──► GATE 4: FIX & HARDEN (Green)
```

| Gate | Nome | Output obrigatório (em memória) | ⛔ Bloqueante se |
|------|------|----------------------------------|------------------|
| 0 | TRIAGE | Severidade P0-P3 + ambiente + owner + SLA | sem severidade **ou** ambiente |
| 1 | REPRODUCE | Repro mínima + teste que falha (Red) + evidência | sem repro determinística **ou** flaky sem seed |
| 2 | ISOLATE | Matriz de hipóteses + `arquivo:linha` + estado incorreto | sem matriz, 1 hipótese só, ou sem `arquivo:linha` |
| 3 | ROOT CAUSE | Tipo canônico + cadeia causal + 5 Porques + Ishikawa | descreve o sintoma como causa |
| 4 | FIX & HARDEN | Fix mínimo + teste Green + suíte sem regressão + Detector | teste falha, regressão, ou sem Detector |

---

## Gate 0 — TRIAGE

**Objetivo:** Priorizar, definir impacto e **identificar o ambiente** (Safety Gate) antes de investigar.

```markdown
**Triage:** P0|P1|P2|P3 — [uma linha clara de impacto]
**Ambiente:** DEV | HOMOLOGACAO | PRODUCAO (Evidência OBSERVED: branch/commit/.env)
**Owner:** [responsável]
**SLA:** P0: 2h | P1: 4h | P2: 1 dia | P3: backlog
**Módulo/Rota/Tabela afetada:** [ex: /api/v1/checkout, tabela payments]
```

Classificação:
- **P0**: Sistema fora do ar, perda de dados, transações incorretas em produção
- **P1**: Funcionalidade crítica quebrada sem workaround
- **P2**: Bug com workaround viável ou escopo restrito
- **P3**: Inconsistência cosmética ou débito técnico

**Timebox (escalonamento obrigatório):**
- P0 sem causa raiz em **2h** → escalar imediatamente
- P1 sem causa raiz em **4h** → escalar
- P2 sem progresso em **1 dia** → pair debug

> ⛔ **BLOQUEADO SE**: Severidade ou ambiente não informados. **NÃO** inicie o Gate 1.
> O ambiente identificado aqui governa o Safety Gate em todo o resto do workflow
> (DEV 🟢 ALLOW · HOMOLOGACAO 🟡 ASK 2x · PRODUCAO 🔴 DENY para ações destrutivas).

---

## Gate 1 — REPRODUCE

**Objetivo:** Tornar o bug determinístico e comprovado por código.

**DEVE:**
1. Documentar passos mínimos (3-5 passos) isolando cache, estado anterior e dados sujos
2. Capturar evidência completa: stack trace, mensagem de erro, log de falha, screenshot se UI
3. Criar e executar um **teste de regressão que FALHA AGORA** (Red), colando o log de falha:

```php
it('deve reproduzir o bug #N', function () {
    // Arrange: dados que disparam o bug
    // Act: execução da unidade suspeita
    // Assert: falha hoje, passará no Gate 4
});
```

```javascript
it('should [comportamento esperado] — repro #<id>', () => {
  // Arrange — seed/dados que reproduzem
  // Act — ação que dispara o bug
  // Assert — falha hoje, passará após o Gate 4
});
```

Classificar reprodutibilidade e agir conforme a árvore de decisão:
- `determinístico`: falha em 100% das execuções → teste unitário/integração basta
- `flaky`: falha intermitente → **DEVE** registrar seed, taxa N/M e rodar com `--repeat` (ou `git bisect` se for regressão)
- `env-only`: depende de ambiente → **DEVE** dumpar `env`, `commit`, dump de dados anonimizado e `docker diff`

**Critério de saída:**
- [ ] Bug reproduzido consistentemente OU flaky com seed/taxa documentada
- [ ] Passos mínimos documentados
- [ ] Evidência capturada em texto
- [ ] Teste que falha criado e **executado** (log de falha colado)

> ⛔ **BLOQUEADO SE**: "funciona na minha máquina" sem dump comparativo, ou teste de reprodução não executado.

---

## Gate 2 — ISOLATE

**Objetivo:** Provar ONDE a falha nasce no código, não onde o sintoma explode.

**Matriz de Hipóteses Falsificáveis (mínimo 2, sempre falsificáveis)**:

| # | Hipótese | Teste de Falsificação | Resultado | Evidência OBSERVED |
|---|---|---|---|---|
| H1 | [ex: binding faltando na view X] | [ex: adicionar log na linha Y] | REFUTADA/CONFIRMADA | [log: var=null] |
| H2 | [ex: query retorna null por WHERE errado] | [ex: rodar query isolada] | REFUTADA/CONFIRMADA | [query log] |

**Toolbox — escolha a técnica que PROVA, não a que é fácil:**
- `git bisect` para regressões (encontra o commit culpado)
- Bisseção por feature flag / config toggle
- `binary search` no código (comentar metade, observar o sintoma)
- Logging estratégico em 2 pontos (entrada e saída da unidade suspeita)
- Tracing / query log / dump de estado
- Diferencial: comparar execução que passa vs execução que falha

**Obrigatório responder (em texto):**
- `Arquivo:Linha` exato: ex. `app/Services/PaymentService.php:84`
- Variável/estado incorreto: ex. `tenant_id = null`, esperado inteiro positivo
- Suposição refutada: ex. `o input estava correto, a falha é no transform`

> ⛔ **BLOQUEADO SE**: Sem matriz, apenas 1 hipótese, ou sem `arquivo:linha` demonstrado com log/trace/bisect.

---

## Gate 3 — ROOT CAUSE

**Objetivo:** Compreender o MECANISMO do problema (não o sintoma).

**DEVE:**

1. Classificar em 1 dos 7 tipos canônicos:
   - `logic`: Erro algorítmico, condicional invertida, off-by-one
   - `data`: Estado inconsistente no banco, schema desatualizado
   - `concurrency`: Race condition, deadlock
   - `config`: Variável de ambiente ausente, flag invertida
   - `dependency`: Breaking change em pacote upstream
   - `env`: Diferença entre SO, extensão ausente
   - `integration`: Timeout de API externa, contrato quebrado

2. Aplicar **5 Porques** completo + checar com **Ishikawa** (mínimo 2 técnicas de causa raiz):

```
Sintoma: "formulário não submete"
  Por quê? validação falha → Por quê? campo null → Por quê? binding não funcionou
  → Por quê? falta wire:model → Por quê? template copiado sem ajustar
Causa raiz: template copiado sem ajustar os bindings
Tipo: logic
```

3. Escrever a cadeia causal com links de `arquivo:linha`:

```markdown
**Cadeia causal:** view X:18 (input sem binding) → controller Y:42 (recebe null) → validação falha → sintoma
**Correlação vs causalidade:** [ex: cache limpo mascarava, mas a causa era o WHERE]
**Contribuintes:** [ex: falta de type check, ausência de teste de contrato]
```

> ⛔ **BLOQUEADO SE**: Descrever o sintoma como causa, não classificar o tipo, ou apresentar cadeia sem `arquivo:linha`.

---

## Gate 4 — FIX & HARDEN

**Objetivo:** Aplicar o menor fix possível, validar que o teste passa, criar imunidade.

**DEVE, nesta ordem:**

1. Confirmar que o teste **ainda falha** (Red) — colar log
2. Implementar o **fix cirúrgico mínimo** — **NÃO** refatorar no mesmo diff
3. Confirmar que o teste **agora passa** (Green) — colar log
4. Executar a suíte relevante completa — **zero regressões** (colar resumo)
5. Declarar Blast Radius e comando de rollback:

```markdown
**Blast radius:** arquivos: [X.php, Y.php] | tabelas: [payments, parcels] | rotas: [/api/*]
**Rollback:** `git revert <commit>` ou feature flag OFF
```

6. Implementar **Prevenção em 3 Níveis** (pelo menos o Detector é obrigatório):
   - 🛡️ **Nível 1 — Detector (OBRIGATÓRIO)**: Teste de regressão que quebrará se o bug retornar
   - 🚧 **Nível 2 — Barreira**: Tipagem estrita, constraint no banco, validação, lint
   - 📖 **Nível 3 — Runbook**: Documentação operacional para P0/P1

> ⛔ **BLOQUEADO SE**: Teste ainda falha, regressão na suíte, ou sem Detector.

---

## Anti-Patterns — NÃO DEVE

| ❌ Errado | ✅ Certo |
|---|---|
| "Acho que é cache, vou limpar" | Provar com matriz de hipóteses falsificáveis |
| Adicionar try-catch para esconder o erro | Corrigir a causa raiz |
| Refatorar junto com o fix | Fix mínimo isolado; refatorar depois via `/clearer-refactor` |
| Corrigir sem teste que falha antes | Sempre teste de repro antes (Red) e depois (Green) |
| Fix sem blast radius / rollback | Declarar impacto e reversão |
| Descrever o sintoma como causa raiz | Chegar ao mecanismo com 5 Porques + Ishikawa |

---

## Saída Final: Debug Report (lição embutida)

Ao completar o Gate 4, **DEVE** retornar um único bloco markdown no chat. Nenhum arquivo é
criado automaticamente — a persistência é decisão consciente do humano/orquestrador.

```markdown
# Debug Report — <slug-do-bug> — <YYYY-MM-DD>

**Triage:** P<N> | **Tipo:** logic|data|concurrency|config|dependency|env|integration | **Arquivo:** `path:linha`
**Ambiente:** DEV/HML/PRD | **Commit:** <hash>

## 1. Sintoma
[Comportamento observado vs esperado]

## 2. Reprodução (Gate 1)
- Passos: 1. ... 2. ... 3. ...
- Classificação: determinístico | flaky | env-only
- Teste de Repro: FALHOU → log capturado

## 3. Isolamento (Gate 2)
- Matriz: H1 REFUTADA — [evidência] | H2 CONFIRMADA — [evidência]
- Local: `arquivo:linha` — estado incorreto: `var=valor`

## 4. Causa Raiz (Gate 3)
- Tipo: [tipo canônico]
- Cadeia causal: [fluxo com arquivo:linha]
- 5 Porques: [resumo]
- Contribuintes: [fatores que facilitaram]

## 5. Correção (Gate 4)
- Fix mínimo: [resumo, sem refatoração]
- Blast Radius: [arquivos/tabelas/rotas]
- Rollback: `git revert <hash>`

## 6. Evidências
- Teste de Repro antes: FALHOU ✓ [log curto]
- Teste de Repro depois: PASSOU ✓ [log curto]
- Suíte Geral: PASSOU (0 regressões) ✓

## 7. Prevenção (3 Níveis)
- [x] Detector: [nome do teste de regressão]
- [ ] Barreira: [constraint/validação/type]
- [ ] Runbook: [link, se P0/P1]

## 8. Lição Aprendida
**Sintoma:** [...]
**Causa raiz:** [...]
**Correção:** [...]
**Como evitar:** [1-3 bullets acionáveis]
**Tags:** [ex: #laravel #eloquent #n+1]
```

> **Deseja registrar esta lição como memória permanente?**
> A seção `## 8. Lição Aprendida` já é lesson-ready. Para persistir no projeto
> (`.dev-memory/learned-lessons.md`) ou em memória global, use **`/learned-lesson`**
> com o conteúdo da seção 8 como payload. **Sem resposta = encerra apenas como relatório.**

---

## Checklist de Done (todos DEVEM estar marcados)

- [ ] Gate 0 — triado (severidade P + ambiente OBSERVED + owner + SLA)
- [ ] Gate 1 — repro com teste que falha (log colado)
- [ ] Gate 2 — matriz com ≥2 hipóteses e `arquivo:linha` provado
- [ ] Gate 3 — tipo canônico + cadeia causal + 5 Porques + Ishikawa
- [ ] Gate 4 — fix mínimo + teste Green + suíte sem regressão + Detector
- [ ] Debug Report retornado com a seção 8 (lição) + pergunta de persistência

> Se qualquer item não estiver marcado, o debug **NÃO** está completo.
