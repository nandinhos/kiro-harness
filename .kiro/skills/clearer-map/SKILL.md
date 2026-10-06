---
name: clearer-map
description: >-
  Mapeamento de codebase e descoberta técnica. Produz um mapa estrutural do projeto
  com stack, entrypoints, convenções, testes e dependências em formato auditável.
---

# CLEARER Map — Mapeamento de Codebase

Descoberta técnica sistemática do repositório para orientar qualquer tarefa de engenharia subsequente.

---

## Objetivo

Produzir um **Evidence Pack** completo do projeto: stack, estrutura, convenções, testes, branches e dependências — tudo em `OBSERVED`.

---

## Processo de Mapeamento

### 1. Identificação da Stack

```bash
# Detectar linguagem e framework
ls -la *.json *.toml *.lock *.xml 2>/dev/null
cat composer.json 2>/dev/null | head -30
cat package.json 2>/dev/null | head -30
cat pyproject.toml 2>/dev/null | head -20
```

### 2. Estrutura do Projeto

```bash
# Estrutura de alto nível (sem vendor/node_modules)
find . -maxdepth 3 -type d -not -path '*/\.*' -not -path '*/vendor/*' -not -path '*/node_modules/*'
```

### 3. Entrypoints

- Arquivo principal da aplicação
- Arquivo de rotas
- Controllers/handlers principais
- Jobs/queues relevantes

### 4. Convenções de Código

- Padrão de nomenclatura (snake_case, camelCase, PascalCase)
- Estrutura de diretórios
- Ferramentas de linting configuradas
- Formatadores automáticos

### 5. Estratégia de Testes

```bash
# Identificar framework de testes
ls tests/ 2>/dev/null
cat phpunit.xml 2>/dev/null | head -20
cat vitest.config.* 2>/dev/null | head -20
cat pytest.ini 2>/dev/null
```

### 6. Git e Branches

```bash
git branch -a
git log --oneline -10
git remote -v
```

### 7. Ambiente e Configuração

```bash
# Identificar ambiente atual
git branch --show-current
cat .env.example 2>/dev/null | grep -v "^#" | grep -v "^$" | head -20
```

---

## Formato de Saída: Evidence Pack

```markdown
## Evidence Pack — <nome-do-projeto> — <YYYY-MM-DD>

### Stack (OBSERVED)
- Linguagem: [versão]
- Framework: [versão]
- Banco de dados: [tipo/versão]
- Gerenciador de pacotes: [ferramenta/versão]

### Estrutura
- Entrypoint principal: [arquivo]
- Rotas: [arquivo/diretório]
- Controllers: [padrão]
- Modelos/Entidades: [padrão]
- Testes: [diretório e framework]

### Convenções
- Nomenclatura: [padrão observado]
- Linting: [ferramenta/config]
- Formatação: [ferramenta/config]

### Git & Ambiente
- Branch atual: [nome] — OBSERVED
- Ambiente: DEV | HML | PRD — OBSERVED via [evidência]
- Branches disponíveis: [lista]

### Testes
- Framework: [nome]
- Comando canônico: [comando]
- Cobertura configurada: sim/não

### Dependências Notáveis
- [pacote]: [versão] — [propósito]

### Riscos e Alertas Identificados
- [risco observado]: [descrição]

### Pontos de Atenção para Tarefas Futuras
- [área sensível]: [nota]
```

---

## Uso Típico

Execute esta skill antes de qualquer tarefa nova em um projeto desconhecido ou como primeiro passo do protocolo CLEARER (L — Load Context).
