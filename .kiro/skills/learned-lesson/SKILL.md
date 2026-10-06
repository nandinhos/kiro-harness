---
name: learned-lesson
description: >-
  Persistência de lições técnicas aprendidas. Registra conhecimento técnico adquirido
  em sessões de debugging, features ou incidentes para evitar recorrência futura.
version: 2.0.0
---

# Learned Lesson — Persistência de Conhecimento Técnico

Registre lições técnicas aprendidas de forma estruturada para que nenhum agente volte a cometer o mesmo erro.

---

## Quando Usar

- Após resolver um bug não-óbvio com causa raiz identificada
- Após descobrir uma limitação de biblioteca ou framework
- Após identificar um anti-padrão que causou incidente
- Após descobrir uma armadilha de ambiente ou configuração
- Quando uma suposição comum se provou incorreta com evidência

---

## Formato Canônico da Lição

```markdown
## Learned Lesson — <slug-descritivo> — <YYYY-MM-DD>

### Contexto
**Projeto**: [nome do projeto ou GLOBAL para lição universal]
**Stack**: [linguagem/framework/versão relevante]
**Categoria**: bug | performance | security | architecture | tooling | environment

### O Que Aconteceu (OBSERVED)
[Descrição factual do problema encontrado, sem interpretação]

### Causa Raiz Identificada
[Mecanismo técnico preciso que causou o problema]

### Solução Aplicada
[Fix ou workaround com evidência de funcionamento]

### Como Detectar no Futuro
[Sintomas, mensagens de erro ou padrões que indicam este problema]

### Como Prevenir
[Mudança de processo, tipagem, teste ou constraint que previne recorrência]

### Teste de Regressão
[Nome ou descrição do teste que detectará se o problema voltar]

### Referências
- [link para PR, issue, documentação]

### Tags
[ex: #laravel #eloquent #n+1 #performance]
```

---

## Persistência Local (sem MCP)

Se não há sistema de memória disponível, persista no arquivo do projeto:

```bash
# Criar ou adicionar ao arquivo de lições do projeto
cat >> .dev-memory/learned-lessons.md << 'EOF'
[conteúdo da lição]
EOF
```

Ou criar o arquivo se não existir:
```bash
mkdir -p .dev-memory
touch .dev-memory/learned-lessons.md
```

---

## Exemplos de Lições Canônicas

### Exemplo: Bug de N+1

```markdown
## Learned Lesson — eloquent-eager-loading-n1 — 2026-10-01

### Contexto
**Projeto**: events
**Stack**: Laravel 11 / Eloquent
**Categoria**: performance

### O Que Aconteceu
Endpoint `/api/events` levava 8s para 100 registros. Query log mostrou 101 queries.

### Causa Raiz
`Event::all()` sem `->with('organizer')` causa 1 query por registro.

### Solução
`Event::with('organizer')->get()` — reduzido para 2 queries.

### Como Detectar
Query log mostra padrão repetitivo. Laravel Debugbar mostra "Duplicate Queries".

### Como Prevenir
Revisão obrigatória de `->with()` antes de qualquer query com relacionamentos.

### Tags
#laravel #eloquent #n+1 #performance
```

---

## Consultando Lições Existentes

Antes de investigar um problema, verifique lições existentes:

```bash
# Se houver arquivo de lições
grep -i "palavra-chave" .dev-memory/learned-lessons.md

# Buscar por tag
grep "#tag-relevante" .dev-memory/learned-lessons.md
```
