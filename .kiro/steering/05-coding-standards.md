# 📐 Padrões de Código & Craftsmanship

## Princípios Fundamentais

### Clean Code
- Funções com responsabilidade única (Single Responsibility)
- Nomes expressivos e sem ambiguidade
- Sem comentários óbvios — o código deve ser autoexplicativo
- Comentários apenas para lógica não-óbvia, decisões de arquitetura ou workarounds necessários

### SOLID
- **S**ingle Responsibility: Uma razão para mudar por classe/módulo
- **O**pen/Closed: Aberto para extensão, fechado para modificação
- **L**iskov Substitution: Subtipos devem ser substituíveis por seus tipos-base
- **I**nterface Segregation: Interfaces específicas, não genéricas
- **D**ependency Inversion: Dependa de abstrações, não de implementações concretas

### Tipagem & Segurança
- Tipagem estrita sempre que a linguagem suportar
- Sem `any` implícito em TypeScript
- Sem tipos `mixed` sem justificativa em PHP
- Tratar todos os casos de erro explicitamente — sem silenciar exceções

---

## Padrões por Contexto

### Segurança
- Usar queries parametrizadas (sem SQL injection)
- Validar e sanitizar inputs
- Não expor stack traces em produção
- Não logar dados sensíveis (senhas, tokens, PII)
- Credenciais e segredos sempre via variáveis de ambiente, nunca hardcoded

### Testes
- Cada novo comportamento deve ter cobertura de teste
- Testes devem ser determinísticos (sem dependência de tempo, ordem ou estado externo)
- Mocks e stubs apenas quando necessário — prefira testes de integração reais
- Exit code 0 = sucesso comprovado; qualquer outro = falha a ser reportada

### Performance
- Não otimizar prematuramente
- Identificar o gargalo com evidência antes de otimizar
- N+1 queries são bug, não feature request

### Acessibilidade
- Código de frontend deve seguir padrões WCAG 2.1 AA
- Atributos `aria-*` quando necessário
- Semântica HTML correta

---

## Convenções do Projeto (Adaptar por Repositório)

Ao carregar o contexto (`L — Load Context`), identifique e respeite:
- Framework e versão em uso
- Padrão de nomenclatura do projeto (camelCase, snake_case, PascalCase)
- Estrutura de diretórios e convenções de organização
- Ferramentas de linting e formatação configuradas
- Estratégia de testes existente

**Regra**: Match the existing style. Não introduza novas convenções sem discussão.
