# 🎚️ Risk Dial — Guia Completo

O Risk Dial define o nível de autonomia, overhead de processo e profundidade de revisão para cada tarefa.

---

## Os 3 Níveis

### LOW — Execução Rápida

**Quando aplicar**:
- Leituras e buscas no código
- Formatação e renomeações simples
- Extrações diretas de informação
- Respostas a perguntas sobre o código existente
- Geração de documentação baseada no código

**Comportamento**:
- Execução direta sem overhead de processo
- Response Contract simplificado
- Sem necessidade de suíte de testes completa

**Skills**: `/clearer-map`, `/clearer-audit`, parte de `/clearer-review`

---

### MEDIUM — Execução Contínua (Padrão de Engenharia)

**Quando aplicar**:
- Implementação de novas features
- Correção de bugs
- Refatorações
- Alterações de endpoints ou regras de negócio
- Migrações de banco em DEV

**Comportamento** — Single-Turn End-to-End:
```
INSPECT → PLAN → IMPLEMENT → TEST → REVIEW → AUDIT → REPORT
```

Conduza o ciclo completo **sem pausas artificiais** se o escopo estiver delimitado.
Não encerre a resposta no plano intermediário.

**Skills**: `/clearer-feature`, `/clearer-bugfix`, `/clearer-refactor`, `/clearer-test`

---

### HIGH — Investigação Profunda

**Quando aplicar**:
- Autenticação core e autorização
- Transações financeiras e processamento de pagamentos
- Concorrência crítica e race conditions
- Migrações destrutivas em dados de produção
- Alterações em componentes de segurança
- Mudanças de arquitetura com amplo blast radius

**Comportamento**:
- Investigação profunda antes de qualquer implementação
- Múltiplas iterações de revisão adversarial
- Documentação de riscos e estratégias de rollback
- **Checkpoint humano obrigatório** antes do merge

**Skills**: Combinação de múltiplas skills com aprovação explícita do desenvolvedor

---

## Gestão por Exceção (Quando Pausar)

No nível MEDIUM, interrompa apenas diante de:

1. **Ambiguidade real de requisitos**: Caminhos mutuamente excludentes sem critério para escolha
2. **Safety Gate disparado**: Operação bloqueada (DENY) ou requerendo confirmação (ASK)
3. **Teste falhando após 1 iteração**: Auto-reparo tentado e evidência de falha persistente documentada
4. **HIGH RISK declarado**: Tarefa reclassificada como HIGH após descoberta de complexidade não antecipada

Fora desses casos: **prossiga autonomamente** até a entrega completa.

---

## Exemplos de Classificação

| Tarefa | Risk Dial | Justificativa |
|---|---|---|
| "Qual é o formato do JSON de resposta do endpoint X?" | LOW | Leitura pura |
| "Adicionar campo `phone` ao formulário de cadastro" | MEDIUM | Feature nova com teste necessário |
| "Corrigir typo no label do botão" | LOW | Cosmético, sem comportamento |
| "Implementar 2FA no login" | HIGH | Autenticação core |
| "Refatorar extração de service do controller" | MEDIUM | Sem mudança de comportamento externo |
| "Migrar coluna `user_id` para UUID em produção" | HIGH | Destrutivo em dados reais |
