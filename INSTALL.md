# INSTALL.md — Estado de Instalação do Kiro Harness

## Status: ✅ Operacional

**Instalado em**: `~/.kiro/` (global — todos os projetos)
**Data**: 2026-10-06
**Versão**: v1.0.0

---

## O Que Foi Instalado

### Steering Files (auto-loaded em toda sessão Kiro)

Localização: `~/.kiro/steering/`

| Arquivo | Conteúdo | Linhas |
|---|---|---|
| `00-clearer-protocol.md` | Protocolo CLEARER — 7 etapas, ciclo INSPECT→REPORT | 55 |
| `01-safety-gate.md` | Safety Gate DEV/HML/PRD — ALLOW/ASK/DENY | 51 |
| `02-evidence-semantics.md` | OBSERVED/INFERRED/UNKNOWN + Response Contract | 68 |
| `03-risk-dial.md` | LOW/MEDIUM (Single-Turn)/HIGH + roteamento | 55 |
| `04-ponytail-mode.md` | Escada anti-over-engineering, AST First | 61 |
| `05-coding-standards.md` | SOLID, Clean Code, tipagem, segurança | 62 |

### Skills (ativadas via `/skill`)

Localização: `~/.kiro/skills/`

| Skill | Descrição |
|---|---|
| `clearer` | Dispatcher — analisa e roteia qualquer tarefa |
| `clearer-feature` | Nova feature (8 passos, Response Contract) |
| `clearer-bugfix` | 5 Gates Bloqueantes (Red → Green) |
| `clearer-refactor` | Refatoração cirúrgica com snapshot antes/depois |
| `clearer-review` | Revisão adversarial com checklist completo |
| `clearer-audit` | Auditoria de claims SUPPORTED/UNSUPPORTED |
| `clearer-adhd` | Modo hiperfoco — 10 heurísticas, 1 ação imediata |
| `clearer-test` | Execução determinística, zero fake pass |
| `clearer-map` | Evidence Pack de codebase |
| `learned-lesson` | Persistência de conhecimento técnico |

---

## Como Reinstalar / Atualizar

```bash
# A partir deste repositório
cp -r .kiro/steering/* ~/.kiro/steering/
cp -r .kiro/skills/* ~/.kiro/skills/
```

## Como Aplicar em um Projeto Específico

```bash
# Copiar para o projeto
cp -r .kiro/ /caminho/do/projeto/.kiro/

# O Kiro vai carregar automaticamente ao abrir o projeto
```

## Como Verificar se Está Ativo

Em uma sessão Kiro, execute:
```
/context show
```

Os steering files aparecerão listados sob "context files".
