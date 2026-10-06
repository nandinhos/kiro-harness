# 🎚️ Risk Dial — Automação de Execução

## Os 3 Níveis

| Nível | Critérios | Comportamento |
|---|---|---|
| **LOW** | Leituras, buscas, pequenas renomeações, formatação, extrações diretas. | Execução rápida, contexto enxuto, sem overhead desnecessário. |
| **MEDIUM** | Features novas, correções de bugs, refatores, alterações de endpoints ou regras de negócio. | **Execução Contínua em Turno Único** — ciclo completo sem paradas artificiais. |
| **HIGH** | Autenticação core, transações financeiras, concorrência crítica, migrações destrutivas, segurança. | Investigação profunda, revisão adversarial, auditoria formal e aprovação humana. |

---

## Execução Contínua (Nível MEDIUM — Padrão)

Para tarefas de nível MEDIUM, execute o ciclo completo **sem pausas artificiais**:

```
INSPECT → PLAN → IMPLEMENT → TEST → REVIEW → AUDIT → REPORT
```

**Regras**:
- Não encerre a resposta no plano intermediário
- Prossiga para implementação cirúrgica, testes e validação
- Só interrompa diante de exceção genuína (ver abaixo)

---

## Roteamento por Skill (Risk Dial aplicado)

| Intenção | Skill | Risk Dial |
|---|---|---|
| Nova feature ou melhoria | `/clearer-feature` | MEDIUM |
| Correção de bug | `/clearer-bugfix` | MEDIUM/HIGH |
| Refatoração cirúrgica | `/clearer-refactor` | MEDIUM |
| Revisão de diff/PR | `/clearer-review` | LOW/MEDIUM |
| Auditoria de claims | `/clearer-audit` | LOW |
| Mapeamento de codebase | `/clearer-map` | LOW |
| Execução de testes | `/clearer-test` | MEDIUM |
| Modo hiperfoco | `/clearer-adhd` | LOW/MEDIUM |
| Persistência de lição | `/learned-lesson` | LOW |
| Análise e roteamento | `/clearer` | — |

---

## Checkpoints de Exceção (Quando Pausar)

Interrompa a execução e solicite alinhamento humano **apenas** diante de:

1. Ambiguidade real de negócio com caminhos mutuamente excludentes
2. Safety Gate disparado (DENY ou ASK)
3. Teste falhando após 1 iteração de auto-reparo fundamentada
4. Tarefa declarada explicitamente como HIGH RISK
5. Necessidade de credenciais ou segredos não fornecidos

Fora desses casos, **prossiga autonomamente** até a entrega completa.
