# 🥋 Filosofia Ponytail Mode

> "Entender muito, construir pouco, entregar certo."

A filosofia Ponytail Mode define o comportamento anti-over-engineering do harness. Um engenheiro sênior com décadas de experiência não adiciona complexidade desnecessária — entende profundamente o problema e entrega a solução mais simples e robusta.

---

## Escada de Decisão (Anti-Over-Engineering)

Antes de propor código ou instalar dependências, percorra esta escada de cima para baixo. **Pare no primeiro degrau que resolver o problema**:

1. **Isso precisa mesmo existir?**
   - YAGNI (You Ain't Gonna Need It). Não construa o que não foi solicitado explicitamente.
   - Se há dúvida sobre a necessidade, pergunte antes de implementar.

2. **Já existe na base de código?**
   - Reutilize. Antes de criar, inspecione o projeto em busca de helpers, utilitários e componentes existentes.
   - Proibido duplicar lógica que já existe em outro lugar.

3. **A stdlib resolve?**
   - Zero dependências externas para tarefas triviais.
   - Verifique a biblioteca padrão da linguagem antes de adicionar um pacote.

4. **Existe API nativa da plataforma/runtime?**
   - Priorize recursos nativos (framework, ORM, CLI da plataforma) antes de soluções customizadas.

5. **Uma intervenção cirúrgica resolve?**
   - Escreva o **menor diff funcional possível**.
   - Cada linha adicionada é responsabilidade futura. Minimize o blast radius.

---

## AST First (Inspect Before Edit)

Antes de editar qualquer arquivo:

- Use ferramentas de busca estrutural (`code`, `grep`, `glob`) para entender o estado atual.
- Proibido fazer dumps de arquivos inteiros no contexto — use leitura fatiada e buscas cirúrgicas.
- Se o projeto tiver indexação disponível (knowledge base, MCP), use-a antes de ler arquivos brutos.

---

## Menor Diff Funcional

- Cada alteração deve ser **atômica e focada** no objetivo declarado.
- Não refatore código adjacente que não foi solicitado.
- Não adicione features não solicitadas junto com uma correção.
- Não altere convenções de nomenclatura ou formatação fora do escopo.

---

## Anti-Padrões Ponytail

| Anti-padrão | Comportamento correto |
|---|---|
| Criar nova abstração antes de entender o problema | Inspecionar primeiro, abstrair depois se necessário |
| Adicionar dependência para resolver algo trivial | Verificar stdlib e código existente primeiro |
| Refatorar o entorno durante um bugfix | Fixar o bug, nada mais |
| Propor "melhorias" não solicitadas | Perguntar se há interesse antes de agir |
| Gerar arquivos de configuração desnecessários | Só o que for explicitamente pedido |
