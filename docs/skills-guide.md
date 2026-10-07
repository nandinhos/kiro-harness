# 🛠️ Manual de Skills

Guia de uso de todas as skills disponíveis no Kiro Harness.

---

## Como Ativar uma Skill

No Kiro CLI, use o prefixo `/skill` ou o nome da skill diretamente:

```
/clearer analisar esta tarefa
/clearer-bugfix bug: o pagamento está duplicando
/clearer-feature implementar o sistema de notificações por email
```

---

## Dispatcher: `/clearer`

**Quando usar**: Ponto de entrada universal. Quando não tem certeza de qual skill usar.

**O que faz**:
1. Analisa a intenção da tarefa
2. Identifica o ambiente (DEV/HML/PRD)
3. Classifica o Risk Dial (LOW/MEDIUM/HIGH)
4. Roteia para a skill especializada mais adequada

**Exemplo de uso**:
```
/clearer o login está falhando em produção
/clearer quero adicionar filtros na listagem de pedidos
/clearer analisar o impacto de refatorar o PaymentService
```

---

## `/clearer-feature` — Nova Feature

**Risk Dial**: MEDIUM

**Fluxo**: INSPECT → REQUIREMENTS → IMPACT → PLAN → IMPLEMENT → TEST → REVIEW → REPORT

**Quando usar**: Qualquer nova funcionalidade ou melhoria que introduz novo comportamento.

**O que entrega**: Implementação com testes, diff auditado e Response Contract completo.

---

## `/clearer-bugfix` — Correção de Bug

**Risk Dial**: MEDIUM/HIGH

**Fluxo**: 5 Gates Bloqueantes (TRIAGE → REPRODUCE → ISOLATE → ROOT CAUSE → FIX & HARDEN)

**Quando usar**: Qualquer bug com comportamento incorreto comprovado.

**Diferencial**: Exige teste vermelho (Red) **antes** de qualquer fix. Sem teste reproduzindo o bug, sem avanço.

---

## `/clearer-refactor` — Refatoração

**Risk Dial**: MEDIUM

**Fluxo**: SNAPSHOT → PLAN → REFACTOR → TEST (antes/depois) → REVIEW → REPORT

**Quando usar**: Melhorias de código sem mudança de comportamento externo.

**Regra de Ouro**: Se um teste quebrar, não era refatoração. Era mudança de comportamento.

---

## `/clearer-review` — Revisão de Diff/PR

**Risk Dial**: LOW/MEDIUM

**Quando usar**: Antes de fazer merge de qualquer PR ou ao revisar mudanças de terceiros.

**O que entrega**: Checklist completo (segurança, contratos, testes, padrões) + veredicto APROVADO/BLOQUEADO.

---

## `/clearer-audit` — Auditoria de Claims

**Risk Dial**: LOW

**Quando usar**: Para verificar se afirmações técnicas são sustentadas por evidências reais.

**O que entrega**: Classificação SUPPORTED/PARTIALLY_SUPPORTED/UNSUPPORTED para cada claim.

---

## `/clearer-council` — Deliberação Multi-Perspectiva

**Risk Dial**: HIGH

**Fluxo**: Opiniões independentes (3 perspectivas) → Review cruzado anônimo → Síntese do Chairman

**Quando usar**: Decisão de design/arquitetura/adoção com trade-offs reais e caminhos
mutuamente excludentes ("X ou Y?", "vale adotar Z?"). **Não** para revisar diff
(`clearer-review`) nem auditar claims (`clearer-audit`).

**O que entrega**: Veredicto com consenso, divergências, recomendação fundamentada, riscos
assumidos e condições de reversão.

**Limitação**: no Kiro, as perspectivas são o mesmo modelo em papéis distintos (diversidade
de perspectiva, não de provedor). Ver ADR 006.

---

## `/clearer-adhd` — Modo Hiperfoco

**Risk Dial**: LOW/MEDIUM

**Quando usar**: Tarefas urgentes com escopo definido. Quando preâmbulos consomem mais tempo que a solução.

**Formato**: Ação imediata → resultado observado → próximo passo (< 2 min).

---

## `/clearer-test` — Execução de Testes

**Risk Dial**: MEDIUM

**Quando usar**: Para executar e verificar a suíte de testes com captura completa de evidências.

**Garante**: Zero fake pass — exit code e output bruto capturados e reportados sem interpretação.

---

## `/clearer-map` — Mapeamento de Codebase

**Risk Dial**: LOW

**Quando usar**: Como primeiro passo em qualquer projeto novo ou como `L — Load Context` do CLEARER.

**O que entrega**: Evidence Pack completo — stack, estrutura, convenções, testes, branches.

---

## `/learned-lesson` — Registrar Lição

**Risk Dial**: LOW

**Quando usar**: Após resolver um problema não-óbvio, descobrir uma limitação ou identificar um anti-padrão.

**O que faz**: Persiste o conhecimento em formato estruturado para uso futuro por qualquer agente.
