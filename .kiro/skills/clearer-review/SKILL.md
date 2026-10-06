---
name: clearer-review
description: >-
  Revisão adversarial de diff/PR orientada a evidências. Identifica regressões,
  quebras de contrato, anti-padrões, riscos de segurança e qualidade de testes.
---

# CLEARER Review — Revisão Adversarial de Diff/PR

Revisão crítica e objetiva baseada em evidências. Sem elogios vazios, sem moderação excessiva — apenas análise técnica honesta.

---

## Princípio de Revisão

> Um bom revisor age como um segundo par de olhos adversarial: assume que o código pode estar errado e procura provar isso.

---

## Checklist de Revisão (Execute Sequencialmente)

### 1. Integridade do Diff
- [ ] Não há marcadores de conflito (`<<<`, `===`, `>>>`)
- [ ] Não há código de debug solto (`console.log`, `dd()`, `var_dump()`, `print_r()`)
- [ ] Não há arquivos gerados acidentalmente commitados (`.env`, `vendor/`, `node_modules/`)
- [ ] O diff está focado — não mistura refatoração com mudança de comportamento

### 2. Contratos e Interfaces
- [ ] APIs públicas existentes não foram quebradas sem versioning
- [ ] Tipos e interfaces preservados ou versionados adequadamente
- [ ] Schemas de banco com migration correspondente
- [ ] Contratos de teste não foram alterados sem justificativa

### 3. Segurança
- [ ] Sem SQL injection (queries parametrizadas)
- [ ] Sem credenciais hardcoded
- [ ] Inputs validados e sanitizados
- [ ] Sem exposição de dados sensíveis em logs

### 4. Qualidade de Testes
- [ ] Novos comportamentos têm cobertura de teste
- [ ] Testes são determinísticos (sem dependência de tempo ou estado externo)
- [ ] Testes existentes não foram removidos sem justificativa
- [ ] Casos de borda cobertos

### 5. Padrões de Código
- [ ] Segue as convenções do projeto (nomenclatura, estrutura)
- [ ] Sem duplicação de lógica que já existe
- [ ] Tipagem estrita mantida
- [ ] Tratamento de erros explícito

### 6. Performance & Blast Radius
- [ ] Sem queries N+1 introduzidas
- [ ] Blast radius compreendido e declarado
- [ ] Dependências novas justificadas

---

## Formato de Saída da Revisão

```markdown
## Revisão de Diff/PR — <identificador>

### ✅ Aprovado sem ressalvas
- [item específico que está correto]

### ⚠️ Ressalvas (não bloqueantes)
- [linha/arquivo]: [descrição objetiva do problema e sugestão]

### 🚫 Bloqueantes (MUST FIX antes do merge)
- [linha/arquivo]: [descrição do problema + evidência + impacto]

### 🔒 Segurança
- [achado ou confirmação de ausência de issues]

### 🧪 Testes
- Cobertura nova: [avaliação]
- Regressões identificadas: [nenhuma | lista]

### Veredicto Final
APROVADO | APROVADO COM RESSALVAS | BLOQUEADO — [justificativa concisa]
```

---

## Anti-Padrões de Revisão a Evitar

- ❌ "Parece bom para mim" sem inspeção real do código
- ❌ Aprovar porque "confia no autor"
- ❌ Comentários vagos ("isso poderia ser melhor") sem proposta concreta
- ❌ Ignorar testes porque "é só um bugfix pequeno"
