---
name: clearer-refactor
description: >-
  Refatoração cirúrgica orientada a evidências. Sem mudança de comportamento externo,
  blast radius controlado, testes de regressão antes e depois, menor diff funcional.
---

# CLEARER Refactor — Refatoração Cirúrgica

> **Regra de Ouro**: Refatoração não muda comportamento externo. Se um teste quebrar, não era refatoração — era mudança de comportamento.

---

## Princípios Inegociáveis

1. **Zero Mudança de Comportamento**: A suíte de testes DEVE passar antes E depois sem alteração
2. **Blast Radius Controlado**: Defina explicitamente quais arquivos serão tocados
3. **Menor Diff Funcional**: Não aproveite para refatorar "enquanto estamos aqui"
4. **Uma Refatoração por Vez**: Não misture renomeação + extração + movimentação no mesmo commit

---

## Fluxo de Execução

```
SNAPSHOT → PLAN → REFACTOR → TEST (antes/depois) → REVIEW → REPORT
```

---

### Passo 1: Snapshot (Estado Atual)

1. Execute a suíte de testes e capture o estado atual: todos DEVEM passar
2. Registre o output como referência baseline
3. Documente quais testes cobrem o código a ser refatorado

---

### Passo 2: Plano de Refatoração (Plan)

Defina com precisão:
- **Objetivo**: O que está sendo melhorado? (legibilidade, DRY, SOLID, performance)
- **Escopo**: Arquivos exatos que serão tocados
- **Fora do escopo**: O que NÃO será tocado nesta iteração
- **Técnica utilizada**: Extract Method, Rename, Move, Inline, etc.

---

### Passo 3: Refatoração Cirúrgica (Refactor)

- Aplique uma técnica por commit/iteração
- Siga o padrão de nomenclatura existente no projeto
- Não adicione funcionalidades novas junto com a refatoração
- Não mude interfaces públicas sem consenso explícito

---

### Passo 4: Validação Antes/Depois (Test)

```markdown
**Antes da refatoração:**
- Suíte: [N testes] — PASS (exit code 0)

**Após a refatoração:**
- Suíte: [N testes] — PASS (exit code 0)
- Diff de cobertura: [nenhuma regressão | cobertura melhorada]
```

Se qualquer teste quebrar: **PARE**. Isso não é refatoração.

---

### Passo 5: Response Contract

```markdown
## Response Contract — Refatoração

**Objetivo**: [técnica e motivação]
**Arquivos Alterados**: [lista]
**Testes Antes**: PASS — [N testes]
**Testes Depois**: PASS — [N testes]
**Comportamento Externo**: INALTERADO (OBSERVED)
**Blast Radius**: [N arquivos, N linhas]
**Fora do Escopo**: [o que não foi tocado]
```
