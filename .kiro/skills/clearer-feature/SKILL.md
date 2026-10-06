---
name: clearer-feature
description: >-
  Evidence-driven feature implementation workflow. Conduz a especificação, implementação e
  validação de nova funcionalidade com controle estrito de blast radius, evidências de teste
  e execução contínua single-turn.
---

# CLEARER Feature Engineering Workflow

Implementação de nova funcionalidade com execução contínua e orientação a evidências.

---

## Fluxo de Execução Contínua (Single-Turn End-to-End)

```
INSPECT → REQUIREMENTS → IMPACT → PLAN → IMPLEMENT → TEST → REVIEW → AUDIT & REPORT
```

> **Diretriz de Autonomia:** Conduza os 8 passos em uma única invocação fluida quando os requisitos estiverem definidos. Pause apenas por ambiguidade de requisitos ou Safety Gate ativado.

---

### Passo 1: Inspeção Inicial (Inspect)

1. Identifique a stack e convenções do repositório
2. Verifique o estado do Git: `git status --short`
3. Localize arquivos e testes relacionados à área da nova funcionalidade
4. Identifique o ambiente: `DEV | HOMOLOGACAO | PRODUCAO`

---

### Passo 2: Requisitos e Limites (Requirements & Boundaries)

- **Concrete Goal**: O que exatamente a funcionalidade deve fazer?
- **Explicit Boundaries**: O que está no escopo e o que fica expressamente fora?
- **Contratos a preservar**: APIs, interfaces, tipos ou tabelas que devem permanecer intactos

---

### Passo 3: Mapeamento de Impacto (Impact Map)

- Arquivos que serão criados ou editados
- Blast radius e dependências afetadas
- Riscos identificados (nulos, concorrência, performance)

---

### Passo 4: Plano de Implementação (Implementation Plan)

1. Objetivo técnico e fluxo de dados
2. Arquivos envolvidos e novos símbolos
3. Tipagem estrita e arquitetura defensiva
4. Estratégia de testes automatizados

---

### Passo 5: Implementação Cirúrgica (Implement)

- Aplique o código com excelência: Clean Code, SOLID, tipagem estrita
- Evite atalhos frágeis (`any`, patches cegos) e refatorações oportunistas fora do escopo
- Escreva o **menor diff funcional possível**
- Código autoexplicativo — comentários apenas para lógica não-óbvia

---

### Passo 6: Criação e Execução de Testes (Test)

- Crie ou atualize testes comportamentais para a funcionalidade
- Execute a suíte completa e capture o exit code
- Confirme: exit code 0 = `PASS`, qualquer outro = falha a ser reportada
- Registre o comando executado, saída bruta e resultado

---

### Passo 7: Revisão do Diff (Review)

Verifique no diff gerado:
- ❌ Marcadores de conflito (`<<<`, `===`, `>>>`)
- ❌ `console.log`, `dd()`, `var_dump()` soltos
- ❌ Quebras de contrato em APIs existentes
- ❌ Regressões introduzidas em testes existentes
- ❌ Refatorações oportunistas fora do escopo

---

### Passo 8: Response Contract (Audit & Report)

```markdown
## Response Contract

**Resultado**: PASS | FAIL | PARTIAL
**Ambiente**: DEV | HML | PRD — OBSERVED via [evidência]
**Alterações**:
  - [arquivo]: [descrição da mudança]
**Evidências**:
  - OBSERVED: [comando executado + output]
  - INFERRED: [hipóteses com base em evidências]
  - UNKNOWN: [o que não foi verificado]
**Testes**:
  - Suíte executada: sim/não
  - Exit code: 0
  - Novos testes criados: [N testes]
**Validação**: [critérios de aceite atendidos]
**Pendências**: [bloqueios ou itens para próxima iteração]
**Confiança**: HIGH | MEDIUM | LOW — justificativa
```
