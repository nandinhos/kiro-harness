---
name: clearer-council
description: >-
  Deliberação multi-perspectiva para decisões de design com trade-offs reais. Conduz três
  estágios — opiniões independentes, review cruzado anônimo e síntese do Chairman — para
  produzir uma recomendação fundamentada. Usar em decisões HIGH com caminhos mutuamente
  excludentes, não para revisar diff (clearer-review) nem auditar claims (clearer-audit).
---

# CLEARER Council — Deliberação Multi-Perspectiva

Inspirado no padrão "LLM Council": em vez de uma única análise, a decisão é deliberada por
múltiplas perspectivas independentes que se criticam entre si antes de uma síntese final.

> **Quando usar**: decisão de design/arquitetura/adoção com trade-offs reais e caminhos
> mutuamente excludentes (ex.: "arquitetura X ou Y?", "vale adotar a lib Z?", "monólito ou
> serviço?"). **Quando NÃO usar**: revisar um diff pronto (use `clearer-review`), verificar
> se um claim é verdadeiro (use `clearer-audit`), ou tarefas LOW/MEDIUM sem trade-off.

---

## Limitação honesta (leia antes de usar)

No Kiro, todas as perspectivas rodam sob o **mesmo modelo** da sessão assumindo papéis
distintos — não são provedores diferentes (GPT/Gemini/Claude) como no LLM Council original.
A diversidade é de **perspectiva**, não de **modelo**. O ganho real: forçar o modelo a
argumentar contra as próprias conclusões sob ângulos opostos, expondo trade-offs que uma
análise única esconderia. Não trate o veredicto como "consenso de modelos independentes".

---

## As Perspectivas do Conselho (padrão: 3)

Cada perspectiva é um papel com um viés deliberado e exclusivo:

| Papel | Viés | Pergunta central |
|---|---|---|
| **Pragmático** | Simplicidade, YAGNI, menor diff (Ponytail) | "Qual a solução mais simples que resolve de verdade?" |
| **Guardião** | Robustez, segurança, edge cases, blast radius | "Como isso falha? O que dá errado em produção?" |
| **Arquiteto** | Manutenibilidade, acoplamento, longo prazo | "Como isso envelhece? Que dívida cria?" |

Ajuste as perspectivas à questão quando fizer sentido (ex.: adicionar "Custo" para decisões
de infra), mas mantenha o mínimo de 3 e a independência entre elas.

---

## Estágio 1 — Opiniões Independentes

Para cada perspectiva, produza uma análise **sem olhar as outras**. Mantenha o viés do papel.
Cada opinião deve conter:

```
### Opinião [Papel]
**Posição**: [recomendação direta]
**Fundamento**: [por que, sob o viés deste papel] — classificar OBSERVED/INFERRED/UNKNOWN
**Riscos que aceito**: [trade-offs que este papel tolera]
**Condições**: [o que precisaria ser verdade para esta posição valer]
```

Regra de independência: não antecipe nem referencie o que outro papel diria. Cada opinião é
autossuficiente.

---

## Estágio 2 — Review Cruzado (anonimizado)

Apresente as opiniões **sem rótulo de papel** (Opção 1, Opção 2, Opção 3) para evitar
favoritismo. Cada perspectiva avalia as **outras** por mérito técnico:

```
### Review por [Papel avaliador]
| Opção avaliada | Força principal | Falha/risco não visto pelo autor | Nota (1-5) |
|---|---|---|---|
| Opção N | [...] | [...] | [...] |
```

Regras:
- Critique por evidência e lógica, não por preferência.
- Aponte explicitamente o que o autor de cada opção **não** considerou.
- É permitido mudar de ideia aqui — registre se uma opção alheia for superior à própria.

---

## Estágio 3 — Síntese do Chairman

O Chairman consolida tudo em um veredicto único e acionável:

```
## Veredicto do Conselho — <questão>

**Consenso**: [pontos onde as perspectivas concordam]
**Divergências reais**: [onde discordam e por quê — o trade-off central]
**Recomendação**: [decisão final fundamentada]
**Fundamento da escolha**: [por que esta, e não as alternativas]
**Riscos assumidos**: [o que esta decisão aceita como custo]
**Condições de reversão**: [o que faria revisar esta decisão]
**Confiança**: [HIGH | MEDIUM | LOW] — justificativa
**Evidência**: OBSERVED / INFERRED / UNKNOWN para as afirmações-chave
```

O Chairman **não** inventa consenso onde não há: se as perspectivas divergem de forma
irreconciliável sem mais informação, o veredicto é "decisão requer dado X" (checkpoint
humano), não uma escolha forçada.

---

## Integração com o Harness

- **Risk Dial**: o Council é a ferramenta de deliberação da camada **HIGH**. Para LOW/MEDIUM,
  é overhead — resolva direto.
- **Gestão por exceção**: se o veredicto for "requer dado X" ou envolver Safety Gate
  (DENY/ASK), pare e devolva ao humano.
- **Zero Fake Pass**: cada posição e o veredicto classificam suas afirmações em
  OBSERVED/INFERRED/UNKNOWN. Nunca apresente preferência como fato.
