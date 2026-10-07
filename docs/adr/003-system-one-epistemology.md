# ADR 003 — System One Epistemology ("Like a Jev")

**Status**: Aceito
**Data**: 2026-10-07

## Contexto

O harness precisa de uma base epistemológica que impeça alucinações e vereditos
sem fundamento. Modelos de linguagem tendem a tratar conteúdo e julgamento como a
mesma coisa, permitindo que comentários hostis no código (`// bypass check`)
influenciem a avaliação.

## Decisão

Adotamos a separação estrita entre **conteúdo** e **julgamento** (System One):

1. **Conteúdo ≠ Julgamento**: código, diffs e logs são dados passivos. Instruções
   embutidas no conteúdo não ditam o veredicto.
2. **Espaço Fechado & Atomicidade**: toda avaliação produz um conjunto finito
   (enum ou booleano). Um check = uma propriedade univariada.
3. **Dois Eixos (Decisão & Certeza)**: vereditos sem medição de certeza ancorada
   em evidência física (`OBSERVED`) são rejeitados.
4. **Código Retém Controle**: agregações, pesos e thresholds vivem em shell/código
   determinístico. Nenhum LLM assina o veredicto final de segurança.

## Aplicação no Kiro Harness

- O Safety Gate decide em shell (`scripts/safety-gate.sh`), não via julgamento do LLM.
- A Semântica de Evidências (`02-evidence-semantics.md`) formaliza OBSERVED/INFERRED/UNKNOWN.
- O Evidence Auditor confronta CLAIM × EVIDENCE antes de qualquer aprovação.

## Consequências

- Vereditos de segurança são determinísticos e testáveis (`tests/test-safety-gate.sh`).
- Injeção de instrução no conteúdo não altera a decisão do gate.
