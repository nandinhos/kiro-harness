# 🤖 Guia de Agentes e Subagentes

O Kiro Harness opera com um Engineering Orchestrator que pode despachar para papéis especializados em tarefas de nível HIGH.

---

## Orquestrador Principal

O **Engineering Orchestrator** (agente padrão com o harness ativo) é responsável por:
- Identificar o ambiente e Risk Dial
- Despachar para skills especializadas
- Conduzir o ciclo CLEARER de ponta a ponta para tarefas MEDIUM
- Coordenar papéis especializados para tarefas HIGH

---

## Papéis Especializados (Nível HIGH)

Para tarefas de alto risco, o orquestrador pode ativar papéis com responsabilidades delimitadas:

### 1. Investigator (Investigador)

**Responsabilidade**: Exploração read-only e produção do Evidence Pack.

**O que faz**:
- Mapeia o repositório (stack, entrypoints, dependências)
- Identifica o blast radius da mudança proposta
- Produz o Evidence Pack com tudo classificado em OBSERVED/INFERRED/UNKNOWN
- **NÃO edita arquivos** — apenas lê e analisa

---

### 2. Architect (Arquiteto)

**Responsabilidade**: Design de solução e análise de impacto.

**O que faz**:
- Analisa o Evidence Pack do Investigator
- Define a estratégia de implementação
- Identifica riscos e dependências
- Propõe o plano de implementação com alternativas
- **NÃO implementa** — apenas propõe e valida design

---

### 3. Implementer (Implementador)

**Responsabilidade**: Edição cirúrgica do código.

**O que faz**:
- Segue estritamente o plano do Architect
- Aplica o menor diff funcional possível
- Mantém padrões SOLID, tipagem estrita e Clean Code
- **NÃO cria testes** — apenas implementa o código

---

### 4. Test Engineer (Engenheiro de Testes)

**Responsabilidade**: Execução de testes determinísticos.

**O que faz**:
- Executa a suíte de testes completa
- Captura exit code e output bruto sem interpretação
- Cria testes de regressão para o comportamento implementado
- Reporta falhas com evidência física
- **NÃO mascara falhas** — reporta o estado real

---

### 5. Reviewer (Revisor)

**Responsabilidade**: Revisão adversarial do diff.

**O que faz**:
- Analisa o diff com postura adversarial
- Verifica contratos, segurança, padrões e cobertura
- Emite veredicto APROVADO/BLOQUEADO com evidências
- **NÃO aprova por confiança** — aprova por evidência

---

### 6. Evidence Auditor (Auditor de Evidências)

**Responsabilidade**: Confronto final CLAIM × EVIDENCE.

**O que faz**:
- Lista todos os claims técnicos do ciclo
- Classifica cada um: SUPPORTED/PARTIALLY_SUPPORTED/UNSUPPORTED
- Emite o relatório de auditoria final
- **NÃO aprova** o que não está sustentado por evidência

---

## Pipeline de Subagentes para Tarefas HIGH

```
Investigator → Evidence Pack
      ↓
Architect → Implementation Plan
      ↓
Implementer → Código implementado
      ↓
Test Engineer → Testes executados + evidências
      ↓
Reviewer → Diff auditado
      ↓
Evidence Auditor → Relatório final
      ↓
[Checkpoint humano obrigatório]
      ↓
Deploy/Merge
```

---

## Quando Usar Subagentes vs Execução Direta

| Cenário | Abordagem |
|---|---|
| Tarefa LOW/MEDIUM com escopo claro | Execução direta — ciclo CLEARER em turno único |
| Tarefa HIGH com risco identificado | Pipeline de subagentes com checkpoint humano |
| Bug P0 em produção | Investigator + Test Engineer (foco em evidências, não implementação) |
| Refatoração ampla com muitos arquivos | Architect + Implementer separados por área |
