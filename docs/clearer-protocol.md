# 📜 Protocolo CLEARER — Guia Completo

O Protocolo CLEARER é o ciclo de 7 etapas que governa toda tarefa de engenharia no Kiro Harness.

---

## As 7 Etapas

### C — Concrete Goal (Objetivo Concreto)

Antes de qualquer ação, defina com precisão:
- O que exatamente deve ser feito?
- Qual é o ambiente de execução? (DEV/HML/PRD)
- Quais arquivos estão envolvidos?
- Quais são as restrições e condições de parada?
- Como saberemos que a tarefa está concluída?

**Anti-padrão**: "Melhorar o código" sem critério de aceite objetivo.

---

### L — Load Context (Carregar Contexto)

*Inspect before edit*. Antes de editar qualquer arquivo:

1. Identificar a stack tecnológica
2. Entender a estrutura do projeto
3. Localizar os entrypoints relevantes
4. Ler os testes existentes na área afetada
5. Identificar convenções de nomenclatura e padrões do projeto
6. Verificar o estado do Git (branch, commits recentes)

**Regra**: O que o repositório pode responder, não deve ser assumido.

---

### E — Explicit Boundaries (Limites Explícitos)

Defina com precisão o blast radius:
- O que está **dentro** do escopo?
- O que está **fora** do escopo (explicitamente)?
- Quais contratos, APIs e interfaces devem ser preservados?

**Anti-padrão**: Refatorar código adjacente "enquanto estamos aqui" sem solicitação.

---

### A — Anchors and Examples (Âncoras)

Use como fonte da verdade apenas o que foi encontrado no repositório:
- Código existente e suas convenções
- Testes reais e seus casos de borda
- Schemas e tipos definidos
- Documentação de comportamento esperado

**Anti-padrão**: Assumir que uma função existe antes de encontrá-la.

---

### R — Response Contract (Contrato de Resposta)

Toda entrega relevante deve produzir um contrato auditável:

```markdown
**Resultado**: PASS | FAIL | PARTIAL
**Ambiente**: DEV | HML | PRD — OBSERVED via [evidência]
**Alterações**: [lista de arquivos com descrição]
**Evidências**: [OBSERVED, INFERRED, UNKNOWN]
**Testes**: [comando, exit code, resultado]
**Validação**: [critérios de aceite atendidos/pendentes]
**Pendências**: [bloqueios ou próximos passos]
**Confiança**: HIGH | MEDIUM | LOW
```

---

### E — Enable Evidence (Habilitar Evidências)

Observação direta sobre suposição. Para cada afirmação técnica:
- Use ferramentas para ler, executar e verificar
- Capture outputs reais de comandos
- Registre o exit code de testes
- Classifique cada informação: OBSERVED / INFERRED / UNKNOWN

**Proibido**: "Deve funcionar", "Deve estar passando", "Provavelmente é correto" sem evidência física.

---

### R — Review and Validate (Revisar e Validar)

Escrever código não encerra a tarefa. O ciclo completo é:

```
INSPECT → PLAN → IMPLEMENT → TEST → REVIEW → AUDIT → REPORT
```

A revisão deve ser adversarial: procure ativamente por problemas, não confirme suposições.

---

## Aplicação por Nível de Risco

| Risk Dial | Aplicação do CLEARER |
|---|---|
| **LOW** | Etapas L e A são suficientes. Response Contract simplificado. |
| **MEDIUM** | Ciclo completo em turno único. Response Contract completo. |
| **HIGH** | Ciclo completo com subagentes especializados e aprovação humana. |
