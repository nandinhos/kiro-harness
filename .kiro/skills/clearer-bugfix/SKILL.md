---
name: clearer-bugfix
description: >-
  Systematic Debugging com 5 gates bloqueantes (RFC 2119). Matriz de Hipóteses falsificáveis,
  isolamento determinístico (Red → Minimal Patch → Green), Prevenção em 3 Níveis e integração
  com learned-lesson para retenção permanente de conhecimento.
version: 2.0.0
---

# CLEARER Systematic Debugging Engine v2.0
### Workflow Determinístico de Depuração em 5 Gates Bloqueantes

> **Princípio Fundamental (RFC 2119):**
> Nunca chute a causa. Prove com artefato.
> Sem teste vermelho prévio e sem evidência observada = **SEM AVANÇO**.

---

## Visão Geral dos 5 Gates

```
GATE 0: TRIAGE ──► GATE 1: REPRODUCE (Red) ──► GATE 2: ISOLATE (Hipóteses)
                                                          │
                                                          ▼
                              GATE 3: ROOT CAUSE ──► GATE 4: FIX & HARDEN (Green)
```

---

## Gate 0 — TRIAGE

**Objetivo:** Priorizar, definir impacto e identificar o ambiente antes de investigar.

```markdown
**Triage:** P0|P1|P2|P3 — [uma linha clara de impacto]
**Ambiente:** DEV | HOMOLOGACAO | PRODUCAO (Evidência: branch/commit/.env)
**Owner:** [responsável]
**SLA:** P0: 2h | P1: 4h | P2: 1 dia | P3: backlog
**Módulo/Rota afetada:** [ex: /api/v1/checkout]
```

Classificação:
- **P0**: Sistema fora do ar, perda de dados, transações incorretas em produção
- **P1**: Funcionalidade crítica quebrada sem workaround
- **P2**: Bug com workaround viável ou escopo restrito
- **P3**: Inconsistência cosmética ou débito técnico

> ⛔ **BLOQUEADO SE**: Severidade ou ambiente não informados.

---

## Gate 1 — REPRODUCE

**Objetivo:** Tornar o bug determinístico e comprovado por código.

1. Documentar passos mínimos (3-5 passos) isolando cache e estado sujo
2. Capturar evidência: stack trace, mensagem de erro ou log de falha
3. Criar e executar um **teste de regressão que FALHA AGORA** (Red):

```php
it('deve reproduzir o bug #N', function () {
    // Arrange: dados que disparam o bug
    // Act: execução da unidade suspeita
    // Assert: falha hoje, passará no Gate 4
});
```

Classificar reprodutibilidade:
- `determinístico`: falha em 100% das execuções (teste unitário obrigatório)
- `flaky`: falha intermitente (registrar seed, taxa N/M, executar com `--repeat`)
- `env-only`: depende de ambiente (registrar diff de env e variáveis)

> ⛔ **BLOQUEADO SE**: Teste de reprodução não executado.

---

## Gate 2 — ISOLATE

**Objetivo:** Provar ONDE a falha nasce no código, não onde o sintoma explode.

**Matriz de Hipóteses Falsificáveis (mínimo 2)**:

| # | Hipótese | Teste de Falsificação | Resultado | Evidência OBSERVED |
|---|---|---|---|---|
| H1 | [hipótese 1] | [como falsificar] | REFUTADA/CONFIRMADA | [evidência] |
| H2 | [hipótese 2] | [como falsificar] | REFUTADA/CONFIRMADA | [evidência] |

**Obrigatório responder**:
- `Arquivo:Linha` exato: ex. `app/Services/PaymentService.php:84`
- Variável/estado incorreto: ex. `tenant_id = null`, esperado inteiro positivo

> ⛔ **BLOQUEADO SE**: Sem matriz, apenas 1 hipótese, ou sem `arquivo:linha` demonstrado.

---

## Gate 3 — ROOT CAUSE

**Objetivo:** Compreender o MECANISMO do problema (não o sintoma).

Classificar em 1 dos 7 tipos canônicos:
- `logic`: Erro algorítmico, condicional invertida, off-by-one
- `data`: Estado inconsistente no banco, schema desatualizado
- `concurrency`: Race condition, deadlock
- `config`: Variável de ambiente ausente, flag invertida
- `dependency`: Breaking change em pacote upstream
- `env`: Diferença entre SO, extensão ausente
- `integration`: Timeout de API externa, contrato quebrado

Aplicar os **5 Porques** para chegar à causa raiz real.

> ⛔ **BLOQUEADO SE**: Descrever o sintoma como causa.

---

## Gate 4 — FIX & HARDEN

**Objetivo:** Aplicar o menor fix possível, validar que o teste passa, criar imunidade.

1. Confirmar que o teste **ainda falha** (Red)
2. Implementar o **fix cirúrgico mínimo** — sem refatorações adicionais
3. Confirmar que o teste **agora passa** (Green)
4. Executar a suíte completa — zero regressões
5. Declarar Blast Radius e comando de rollback
6. Implementar **Prevenção em 3 Níveis**:
   - 🛡️ **Nível 1 — Detector (OBRIGATÓRIO)**: Teste que quebrará se o bug retornar
   - 🚧 **Nível 2 — Barreira**: Tipagem estrita, constraint no banco, validação
   - 📖 **Nível 3 — Runbook**: Documentação operacional para P0/P1

> ⛔ **BLOQUEADO SE**: Teste ainda falha, regressão na suíte, ou sem Detector.

---

## Saída Final: Debug Report

```markdown
# Debug Report — <slug-do-bug> — <YYYY-MM-DD>

**Triage:** P<N> | **Tipo:** <tipo> | **Arquivo:** `path:linha`
**Ambiente:** DEV/HML/PRD | **Commit:** <hash>

## 1. Sintoma
[Comportamento observado vs esperado]

## 2. Reprodução (Gate 1)
- Classificação: determinístico | flaky | env-only
- Teste de Repro: FALHOU → log capturado

## 3. Isolamento (Gate 2)
- H1: REFUTADA — [evidência]
- H2: CONFIRMADA — [evidência]
- Local: `arquivo:linha`

## 4. Causa Raiz (Gate 3)
- Tipo: [tipo canônico]
- 5 Porques: [cadeia causal]

## 5. Correção (Gate 4)
- Fix mínimo: [resumo]
- Blast Radius: [arquivos/rotas]
- Rollback: `git revert <hash>`

## 6. Evidências
- Teste de Repro: PASSOU ✓
- Suíte Geral: PASSOU (0 regressões) ✓

## 7. Prevenção
- [x] Detector: [nome do teste]
- [ ] Barreira: [constraint/validação]
- [ ] Runbook: [link]
```

> **Deseja registrar esta lição como memória permanente?**
> Use `/learned-lesson` para persistir o aprendizado.
