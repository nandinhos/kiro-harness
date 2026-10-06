# ⚖️ Semântica de Evidências — Guia Completo

A Semântica de Evidências define como o Kiro Harness classifica e comunica conhecimento técnico, prevenindo alucinações e afirmações sem fundamento.

---

## As 3 Classes Epistêmicas

### OBSERVED — Fato Comprovado

**Definição**: Informação diretamente verificada por leitura de arquivo, execução de comando, teste ou output de ferramenta.

**Exemplos de fontes válidas**:
- Arquivo lido com ferramenta de leitura
- Output de comando executado com exit code
- Resultado de teste com log completo
- Schema de banco verificado na migration
- Log de erro capturado diretamente

**Formato de uso**: "OBSERVED via [fonte]: [informação]"

```markdown
OBSERVED via `git branch --show-current`: branch atual é `dev`
OBSERVED via `cat .env`: APP_ENV=local
OBSERVED via execução de testes: 24 passed, 0 failed (exit code 0)
```

---

### INFERRED — Conclusão Razoável

**Definição**: Hipótese razoável baseada em evidências OBSERVED, mas ainda não formalmente demonstrada por execução ou leitura direta.

**Quando usar**:
- "Com base no padrão visto em outros arquivos, provavelmente..."
- "Dado que a migration N existe, infiro que..."
- "A estrutura sugere que..."

**Regra crítica**: INFERRED deve ser explicitamente marcado como tal e validado antes de ser tratado como OBSERVED.

```markdown
INFERRED: com base no padrão MVC observado nos outros controllers, provavelmente existe um `UserController`.
(não confirmado — necessário verificar)
```

---

### UNKNOWN — Sem Evidência

**Definição**: Não existe evidência suficiente no repositório ou contexto para fazer qualquer afirmação.

**Regra absoluta**: UNKNOWN **nunca** pode silenciosamente virar OBSERVED.

**O que fazer quando UNKNOWN**:
- Declarar explicitamente como UNKNOWN
- Especificar o que seria necessário para tornar OBSERVED
- Não prosseguir baseado em suposição

```markdown
UNKNOWN: não encontrei o arquivo de configuração do queue worker.
Necessário para confirmar: buscar por `queue.php` ou `horizon.php` no diretório config/
```

---

## Auditoria de Claims (SUPPORTED / UNSUPPORTED)

Toda afirmação técnica pode ser auditada:

| Status | Definição |
|---|---|
| **SUPPORTED** | Amparada por OBSERVED (comando, arquivo, teste) |
| **PARTIALLY_SUPPORTED** | Parcialmente demonstrada, ressalvas documentadas |
| **UNSUPPORTED** | Sem evidência física ou evidência contraditória |

---

## Anti-Padrões Proibidos

| Anti-padrão | Classificação Correta |
|---|---|
| "O bug foi corrigido" sem output do teste | UNSUPPORTED → mostre o teste passando |
| "Deve funcionar" sem execução | INFERRED → execute e observe |
| "A API retorna 200" sem curl/log | INFERRED → verifique com evidência |
| "Sem regressões" sem suíte completa | UNSUPPORTED → execute a suíte |
| "O arquivo existe" sem ter lido ou listado | INFERRED → verifique com glob/read |
| "O método está disponível" sem encontrar na codebase | UNKNOWN → busque com search |

---

## Response Contract — Template de Evidências

```markdown
**Evidências**:
  - OBSERVED: git branch mostra `dev` | APP_ENV=local no .env
  - OBSERVED: testes executados — 24/24 passed, exit code 0
  - INFERRED: com base no controller X, o service Y provavelmente segue o mesmo padrão
  - UNKNOWN: não foi possível verificar se há jobs em fila — queue não acessível em DEV
```
