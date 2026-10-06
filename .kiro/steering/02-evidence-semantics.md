# 🔬 Semântica de Evidências

## Classificação Epistêmica Obrigatória

Toda informação técnica relevante deve ser classificada em uma das 3 classes:

| Classe | Definição |
|---|---|
| **`OBSERVED`** | Comprovado diretamente por código lido, arquivo existente, execução de comando, teste ou saída de ferramenta. |
| **`INFERRED`** | Conclusão razoável baseada em evidências observadas, mas ainda não formalmente demonstrada. |
| **`UNKNOWN`** | Não existe evidência suficiente. Nunca pode silenciosamente virar OBSERVED. |

---

## Regra Crítica

> **UNKNOWN nunca pode silenciosamente virar OBSERVED.**

É terminantemente proibido inventar arquivos, classes, métodos, endpoints, tabelas ou regras de negócio.
Se não foi encontrado, reporte como `UNKNOWN` ou `NOT FOUND`.

---

## Auditoria de Claims

Toda alegação de conclusão, compatibilidade ou funcionamento deve ser auditável:

| Status | Definição |
|---|---|
| **`SUPPORTED`** | Amparada por comando executado, linha de código ou teste correspondente. |
| **`PARTIALLY_SUPPORTED`** | Parcialmente demonstrada, com ressalvas explícitas. |
| **`UNSUPPORTED`** | Rejeitada ou não comprovada. |

---

## Response Contract Padrão

Toda entrega relevante deve produzir este contrato de saída:

```
## Response Contract

**Resultado**: [PASS | FAIL | PARTIAL]
**Ambiente**: [DEV | HML | PRD] — OBSERVED via [evidência]
**Alterações**:
  - [arquivo]: [descrição da mudança]
**Evidências**:
  - OBSERVED: [comando executado e output]
  - INFERRED: [hipóteses com base em evidências]
  - UNKNOWN: [o que não foi verificado]
**Testes**:
  - Suíte executada: [sim/não]
  - Exit code: [0 / N]
  - Output: [resumo do resultado]
**Validação**: [critérios de aceite atendidos ou pendentes]
**Pendências**: [bloqueios ou itens para próxima iteração]
**Confiança**: [HIGH | MEDIUM | LOW] — justificativa
```

---

## Anti-Padrões Proibidos

- ❌ "Deve funcionar" sem executar
- ❌ "Testado" sem mostrar o output do teste
- ❌ "Sem regressão" sem rodar a suíte completa
- ❌ "Arquivo existe" sem ter lido ou listado
- ❌ "Método disponível" sem ter encontrado na codebase
