# ADR 005 — Adaptação Native-First (Kiro) do CEH

**Status**: Aceito
**Data**: 2026-10-07

## Contexto

O CEH base foi concebido para o Google Antigravity (IDE + `agy` CLI), com
ferramentas próprias: RTK (compressão de output), Graphify (AST via Tree-Sitter),
context-mode (sandbox SQLite), heartbeat 25s e uma CLI `ceh-*`. O Kiro CLI já
oferece capacidades nativas equivalentes.

Guiados pelo Ponytail Mode ("entender muito, construir pouco, entregar certo"),
decidimos o que portar, adaptar e descartar.

## Decisão

| Capacidade CEH | Decisão no Kiro | Justificativa |
|---|---|---|
| Subagentes especializados | **PORTADO** → `.kiro/agents/*.json` | Mecanismo nativo de custom agents |
| Safety Gate executável | **PORTADO** → hook `PreToolUse` + `scripts/safety-gate.sh` | Hooks nativos com exit code 2 bloqueante |
| Pre-Push CI Gate | **PORTADO** → hook + `scripts/pre-push-gate.sh` | Flight Certificate em shell |
| Evals / falsificabilidade | **PORTADO** → `tests/` | Suíte shell determinística |
| Instalador | **PORTADO** → `install.sh` | — |
| ADRs | **PORTADO** → `docs/adr/` | — |
| RTK (compressão Rust) | **DESCARTADO** | Kiro gerencia contexto nativamente |
| Graphify (AST) | **DESCARTADO** | Ferramenta nativa `code` (tree-sitter + LSP) |
| context-mode (SQLite) | **DESCARTADO** | Gestão de contexto é do Kiro |
| Heartbeat 25s / monitor | **DESCARTADO** | Background process nativo do Kiro CLI |
| Multi-Model Council | **ADIADO** | Depende de múltiplas CLIs externas |

## Consequências

- Zero dependências externas além de `bash`, `git`, `jq` (coreutils).
- Menor superfície de manutenção; aproveita o que o Kiro já faz melhor.
- Fidelidade à técnica do CEH preservada onde agrega valor real.
