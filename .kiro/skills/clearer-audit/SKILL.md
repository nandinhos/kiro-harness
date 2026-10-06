---
name: clearer-audit
description: >-
  Auditoria de claims e conclusões técnicas. Classifica afirmações como SUPPORTED,
  PARTIALLY_SUPPORTED ou UNSUPPORTED com base em evidências físicas observadas.
---

# CLEARER Audit — Auditoria de Claims e Conclusões

Auditoria rigorosa de afirmações técnicas. Cada claim é confrontado com sua evidência física.

---

## Objetivo

Verificar se afirmações técnicas são sustentadas por evidências físicas:
- "O bug foi corrigido" → Existe output do teste passando?
- "Sem regressões" → A suíte completa foi executada?
- "A migration está correta" → O schema foi validado?
- "O endpoint responde 200" → Existe log/curl de evidência?

---

## Classificação de Claims

| Status | Definição |
|---|---|
| **`SUPPORTED`** | Amparada por comando executado, linha de código ou teste correspondente |
| **`PARTIALLY_SUPPORTED`** | Parcialmente demonstrada, com ressalvas explícitas documentadas |
| **`UNSUPPORTED`** | Afirmação sem evidência física ou evidência contradiz a afirmação |

---

## Processo de Auditoria

### 1. Inventário de Claims

Liste cada afirmação técnica do contexto auditado:
```markdown
| # | Claim | Tipo |
|---|---|---|
| C1 | "O teste X passou" | Resultado de teste |
| C2 | "Sem regressões" | Cobertura de suíte |
| C3 | "O endpoint valida Y" | Comportamento de API |
```

### 2. Confronto Claim × Evidência

Para cada claim, busque a evidência física:
- Execute o comando relevante
- Leia o arquivo referenciado
- Verifique o log/output mencionado

### 3. Classificação Final

```markdown
| # | Claim | Evidência Encontrada | Status |
|---|---|---|---|
| C1 | "Teste X passou" | Output: `PASS 1/1` | SUPPORTED |
| C2 | "Sem regressões" | Nenhum output de suíte completa | UNSUPPORTED |
| C3 | "Endpoint valida Y" | Código verificado em linha 84 | SUPPORTED |
```

---

## Formato de Saída da Auditoria

```markdown
## Audit Report — <contexto auditado> — <YYYY-MM-DD>

### Claims Auditados: <N total>
- SUPPORTED: <N>
- PARTIALLY_SUPPORTED: <N>
- UNSUPPORTED: <N>

### Detalhamento

**C1 — SUPPORTED**
- Claim: "[afirmação exata]"
- Evidência: [comando executado / arquivo lido / output observado]
- Conclusão: Afirmação verificada

**C2 — UNSUPPORTED**
- Claim: "[afirmação exata]"
- Evidência: [nenhuma encontrada / evidência contraditória]
- Conclusão: Afirmação não pode ser verificada. Ação necessária: [o que fazer]

### Veredicto Final
AUDITORIA APROVADA | AUDITORIA PARCIAL | AUDITORIA REPROVADA

### Ações Recomendadas
- [ ] [ação concreta para claims UNSUPPORTED]
```

---

## Regras Críticas da Auditoria

- **UNKNOWN nunca vira OBSERVED** automaticamente
- Ausência de evidência = `UNSUPPORTED`, não `ASSUMED`
- Claims de terceiros (humanos ou agentes) recebem o mesmo rigor
- Uma auditoria que aprova tudo sem questionamentos é uma auditoria inválida
