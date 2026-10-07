# 🛡️ Kiro Harness — CLEARER Engineering para Kiro CLI

> Filosofia CEH (CLEARER Engineering Harness) adaptada nativamente para o **Kiro CLI**.

[![Kiro CLI](https://img.shields.io/badge/Kiro-CLI-blue.svg)](https://github.com/aws/kiro)
[![CEH](https://img.shields.io/badge/CEH-v1.0.0-purple.svg)](#)
[![Risk Dial](https://img.shields.io/badge/Risk%20Dial-LOW%20|%20MEDIUM%20|%20HIGH-orange.svg)](#o-risk-dial)

---

## 📖 Visão Geral

O **Kiro Harness** é a implementação da filosofia **CLEARER Engineering** para o ecossistema Kiro CLI.

Em vez de prompts vagos ou suposições não comprovadas, o harness opera com os mais altos padrões de **Staff Software Engineering**:

- **Orientação a Evidências**: Toda afirmação técnica deve ser sustentada por comandos reais, testes e outputs observados. Proibido afirmar "corrigido", "testado" ou "sem regressão" sem evidência física.
- **Safety Gate por Ambiente**: Rigores diferenciados para `DEV` (liberdade com salvaguarda), `HOMOLOGACAO` (confirmação obrigatória) e `PRODUCAO` (comandos destrutivos bloqueados).
- **Protocolo CLEARER**: Ciclo determinístico `Concrete Goal → Load Context → Explicit Boundaries → Anchors → Response Contract → Evidence → Review`.
- **Risk Dial**: Automação de execução em 3 níveis (LOW, MEDIUM, HIGH) com Single-Turn End-to-End para MEDIUM.
- **Semântica de Claims**: Classificação epistêmica `OBSERVED / INFERRED / UNKNOWN` com auditoria `SUPPORTED / UNSUPPORTED`.
- **Filosofia Ponytail Mode**: "Entender muito, construir pouco, entregar certo." Escada de decisão anti-over-engineering, menor diff funcional, AST First.
- **Zero Fake Pass & Anti-Alucinação**: Proibido inventar arquivos, métodos, endpoints ou regras de negócio inexistentes.

---

## 🗂️ Estrutura do Harness

```
kiro-harness/
├── .kiro/
│   ├── steering/               # Regras globais carregadas automaticamente no Kiro
│   │   ├── 00-clearer-protocol.md      # O Protocolo CLEARER (núcleo)
│   │   ├── 01-safety-gate.md           # Safety Gate por Ambiente
│   │   ├── 02-evidence-semantics.md    # Semântica de Evidências
│   │   ├── 03-risk-dial.md             # O Risk Dial
│   │   ├── 04-ponytail-mode.md         # Filosofia Ponytail Mode
│   │   └── 05-coding-standards.md      # Padrões de Código
│   ├── skills/                 # Skills ativadas por demanda (/skill) — 11 skills
│   ├── agents/                 # Subagentes especializados (custom agents JSON)
│   │   ├── investigator.json           # Exploração read-only → Evidence Pack
│   │   ├── architect.json              # Design de solução → Implementation Plan
│   │   ├── implementer.json            # Edição cirúrgica
│   │   ├── test-engineer.json          # Testes determinísticos
│   │   ├── reviewer.json               # Revisão adversarial
│   │   ├── evidence-auditor.json       # Confronto CLAIM × EVIDENCE
│   │   └── prompts/                    # System prompts dos agentes
│   └── hooks/                  # Enforcement executável (hooks nativos do Kiro)
│       ├── safety-gate.json            # PreToolUse — bloqueia destrutivos por ambiente
│       ├── pre-push-ci-gate.json       # PreToolUse — Zero-Tolerance Pipeline Red
│       └── session-start.json          # SessionStart — injeta ambiente/política
├── scripts/                    # Núcleo executável (shell, zero deps externas)
│   ├── detect-env.sh                   # Detector de ambiente DEV/HML/PRD
│   ├── safety-gate.sh                  # Avaliação do Safety Gate
│   ├── pre-push-gate.sh                # Validação do Flight Certificate
│   ├── test-runner.sh                  # Suíte + assinatura do certificado
│   ├── setup-branches.sh               # Topologia Clássica/Enterprise
│   └── hooks/                          # Adaptadores dos hooks (STDIN → exit code)
├── tests/                      # Suíte de testes determinística (106 asserções)
│   ├── run-all-tests.sh                # Orquestrador — exit 0 = tudo verde
│   ├── test-structure.sh               # Presença de artefatos
│   ├── test-schema.sh                  # Schema de skills/agents/hooks
│   ├── test-safety-gate.sh             # Adversarial do Safety Gate
│   ├── test-pre-push-gate.sh           # Pre-Push Gate em sandbox
│   └── lib/assert.sh                   # Mini-lib de asserção
├── .github/workflows/ci.yml    # CI — roda a suíte canônica
├── install.sh                  # Instalador (global ou por projeto)
├── AGENTS.md                   # Regras do harness para agentes
└── docs/
    ├── adr/                    # Architecture Decision Records (003, 004, 005)
    ├── clearer-protocol.md     # Guia completo do Protocolo CLEARER
    ├── safety-gate.md          # Guia do Safety Gate
    ├── evidence-semantics.md   # Semântica de Evidências
    ├── risk-dial.md            # O Risk Dial
    ├── ponytail-mode.md        # Filosofia Ponytail Mode
    ├── coding-standards.md     # Padrões de código
    ├── skills-guide.md         # Manual de Skills
    └── agents-guide.md         # Guia de Subagentes
```

---

## ⚡ Como Usar no Kiro CLI

### Configuração Global (recomendado)

Instale com o script dedicado:

```bash
# Global (~/.kiro) — todos os projetos
./install.sh

# Em um projeto específico
./install.sh --project /caminho/do/projeto
```

> ⚠️ Os hooks de bloqueio (`safety-gate`, `pre-push-ci-gate`) são distribuídos
> com `"enabled": false`. Revise e ative conscientemente após validar na sua máquina.

### Rodando a suíte de testes

```bash
./tests/run-all-tests.sh        # exit 0 = tudo verde
./scripts/test-runner.sh        # roda a suíte e assina o Flight Certificate
```

### Skills Disponíveis

| Skill | Descrição | Uso |
|---|---|---|
| `/clearer` | Dispatcher principal — analisa e roteia a tarefa | Ponto de entrada geral |
| `/clearer-feature` | Nova feature ou melhoria | `Implementar X` |
| `/clearer-bugfix` | Diagnóstico e correção de bug (5 gates) | `Bug: Y` |
| `/clearer-refactor` | Refatoração cirúrgica | `Refatorar Z` |
| `/clearer-review` | Revisão adversarial de diff/PR | `Revisar diff` |
| `/clearer-audit` | Auditoria de claims e conclusões | `Auditar claims` |
| `/clearer-council` | Deliberação multi-perspectiva para decisões com trade-offs | `Decidir X ou Y` |
| `/clearer-adhd` | Modo hiperfoco — 1 ação imediata, zero preâmbulos | Alta densidade |
| `/clearer-test` | Execução e verificação determinística de testes | `Rodar testes` |
| `/clearer-map` | Mapeamento de codebase e descoberta técnica | `Mapear projeto` |
| `/learned-lesson` | Persistência de lições técnicas aprendidas | `Registrar lição` |

---

---

## 🤖 Subagentes Especializados (tarefas HIGH)

Pipeline de papéis com autoridade delimitada, ativáveis via `/agent`:

| Agente | Papel | Tools |
|---|---|---|
| `investigator` | Exploração read-only → Evidence Pack | read, web |
| `architect` | Design de solução → Implementation Plan | read, web |
| `implementer` | Edição cirúrgica (não cria testes) | read, write, shell |
| `test-engineer` | Testes determinísticos + regressão | read, write, shell |
| `reviewer` | Revisão adversarial do diff | read, shell |
| `evidence-auditor` | Confronto CLAIM × EVIDENCE | read |

---

## ⚙️ Enforcement Executável (Hooks)

| Hook | Trigger | O que faz |
|---|---|---|
| `safety-gate` | PreToolUse | Bloqueia (exit 2) destrutivos em PRD e catástrofes; pede confirmação em HML |
| `pre-push-ci-gate` | PreToolUse | Zero-Tolerance Pipeline Red — exige Flight Certificate verde |
| `session-start-env` | SessionStart | Injeta ambiente/branch/política no contexto |

> Distribuídos com `enabled:false`. Ative após revisar — hooks de bloqueio interceptam comandos reais.

---

## 🛡️ Níveis de Rigor por Ambiente

| Ambiente | Identificação | Política | Ações Destrutivas |
|---|---|:---:|---|
| **`DEV` / `TEST`** | Branch `dev/*`, `APP_ENV=local/testing` | 🟢 `ALLOW` | Permitidas com salvaguarda de backup local |
| **`HOMOLOGACAO`** | Branch `staging/homolog`, `APP_ENV=staging` | 🟡 `ASK (2 Alertas)` | Confirmação obrigatória em 2 etapas |
| **`PRODUCAO`** | Branch `main/master`, `APP_ENV=production` | 🔴 `DENY` | FORA DE COGITAÇÃO — bloqueio absoluto |

---

## 🥋 Filosofia Ponytail Mode

Escada de decisão anti-over-engineering:

1. **Isso precisa existir?** — YAGNI. Não construa o que não foi pedido.
2. **Já existe na base de código?** — Reutilize. Não duplique.
3. **A stdlib resolve?** — Zero dependências externas para tarefas triviais.
4. **Existe API nativa?** — Priorize recursos nativos da plataforma.
5. **Uma intervenção cirúrgica resolve?** — Escreva o menor diff funcional possível.

---

## 📚 Documentação

- [Protocolo CLEARER](./docs/clearer-protocol.md)
- [Safety Gate](./docs/safety-gate.md)
- [Semântica de Evidências](./docs/evidence-semantics.md)
- [Risk Dial](./docs/risk-dial.md)
- [Ponytail Mode](./docs/ponytail-mode.md)
- [Padrões de Código](./docs/coding-standards.md)
- [Manual de Skills](./docs/skills-guide.md)
- [Guia de Agentes](./docs/agents-guide.md)

---

## 🔗 Referências

- Repositório de origem: [antigravity-clearer-engineering-harness](https://github.com/nandinhos/antigravity-clearer-engineering-harness)
- Kiro CLI: Ferramenta AI CLI da AWS

---

*Kiro Harness v2.0.0 — Adaptado da filosofia CEH para o Kiro CLI*
