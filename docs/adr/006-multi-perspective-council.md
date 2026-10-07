# ADR 006 — Council Multi-Perspectiva (adaptação do LLM Council)

**Status**: Aceito
**Data**: 2026-10-07

## Contexto

A ferramenta [llm-council](https://github.com/karpathy/llm-council) (Karpathy) popularizou um
padrão de deliberação: a mesma questão é enviada a múltiplos LLMs, que se avaliam mutuamente
de forma anônima, e um "Chairman" sintetiza a resposta final. O CEH base previa algo
equivalente (`ceh-conselho`), classificado como ADIADO no ADR 005 por depender de múltiplas
CLIs/APIs externas.

O harness não tinha mecanismo para **deliberar sobre uma decisão em aberto com trade-offs**.
As peças existentes cobrem outros casos: `clearer-review` revisa um diff; `clearer-audit`
confronta claims com evidência; o pipeline de subagentes atua em sequência.

## Decisão

Implementar o **padrão** do LLM Council como a skill nativa `clearer-council`, e **não**
portar a aplicação original.

### O que foi descartado e por quê
- **App web (FastAPI + React + Vite)**: segunda aplicação dentro de um harness que é shell +
  config declarativa. Viola Ponytail e o princípio native-first (ADR 005).
- **OpenRouter + API key**: introduz segredo, custo e dependência de rede inexistentes hoje.

### O que foi adotado
- Skill pura (`.kiro/skills/clearer-council/SKILL.md`, Opção A) que conduz 3 estágios:
  1. Opiniões independentes (3 perspectivas: Pragmático, Guardião, Arquiteto)
  2. Review cruzado anonimizado
  3. Síntese do Chairman com recomendação fundamentada
- Zero dependências externas. Dispara na camada HIGH do Risk Dial.

### Limitação explícita
No Kiro, todas as perspectivas rodam sob o **mesmo modelo** da sessão assumindo papéis
distintos — não são provedores independentes como no original. A diversidade é de
perspectiva, não de modelo. O ganho é forçar argumentação adversarial contra as próprias
conclusões; não é "consenso de modelos independentes". Documentado na própria skill.

## Consequências

- Preenche a lacuna de deliberação sobre decisões de design sem inflar o harness.
- Caminho de evolução conhecido (Opção B): despachar cada perspectiva para um subagente
  isolado, caso a independência simulada se mostre insuficiente — adotar só sob evidência.
- Fronteira clara: Council delibera decisão; Review avalia diff; Audit confronta claims.
