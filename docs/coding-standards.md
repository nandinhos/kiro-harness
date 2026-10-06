# 📐 Padrões de Código & Craftsmanship — Guia Completo

Princípios de engenharia de alto nível aplicados em todas as implementações do Kiro Harness.

---

## Fundamentos de Qualidade

### Clean Code

- Funções com **responsabilidade única** — uma razão para mudar
- Nomes **expressivos e sem ambiguidade** (`getUserById` > `getUser`, `processPayment` > `process`)
- Funções **curtas** — se não cabe na tela, provavelmente faz coisas demais
- Sem comentários óbvios — o código deve ser autoexplicativo
- Comentários apenas para lógica não-óbvia, decisões de arquitetura ou workarounds documentados

### SOLID

| Princípio | Definição Prática |
|---|---|
| Single Responsibility | Uma classe/função = uma responsabilidade |
| Open/Closed | Extensível sem modificar código existente |
| Liskov Substitution | Subclasses substituem suas bases sem quebrar |
| Interface Segregation | Interfaces focadas, não genéricas |
| Dependency Inversion | Dependa de abstrações, não implementações |

### Tipagem

- Tipagem **estrita** sempre que a linguagem suportar
- Sem `any` implícito em TypeScript
- Sem tipos ambíguos sem justificativa documentada
- Type hints em Python e PHP quando relevante

---

## Segurança (Obrigatório)

- **SQL Injection**: Sempre queries parametrizadas. Nunca concatenação de strings
- **Credenciais**: Nunca hardcoded. Sempre variáveis de ambiente
- **Input Validation**: Todo input externo deve ser validado e sanitizado
- **Logs**: Nunca logar senhas, tokens, PII ou dados sensíveis
- **Error Handling**: Tratar todos os casos de erro explicitamente. Sem silenciar exceções

---

## Testes

- Cada novo comportamento deve ter **cobertura de teste**
- Testes devem ser **determinísticos** — sem dependência de horário, ordem ou estado externo
- **Mocks** apenas quando necessário — prefira testes de integração com dados reais quando possível
- Exit code 0 = PASS; qualquer outro = FAIL a ser investigado
- **N+1 queries** são bugs, não features — teste deve detectá-los

---

## Convenções por Linguagem

### PHP / Laravel
- PSR-12 para estilo de código
- Type hints em parâmetros e retorno de métodos
- Tratamento de nullables com `?Type` ou early return
- Eloquent relationships com eager loading explícito (`->with()`)

### TypeScript / Node.js
- `strict: true` no tsconfig
- Sem `any` — use `unknown` e narrowing
- `const` sobre `let`, `let` sobre `var`
- Async/await sobre Promises encadeadas

### Python
- PEP 8 para estilo
- Type hints com `typing` module
- `f-strings` para interpolação
- Context managers (`with`) para recursos

---

## Performance

- **Não otimize prematuramente** — identifique o gargalo com evidência antes
- **N+1 queries** são bug — use eager loading ou batch queries
- **Caching**: apenas onde há evidência de necessidade, não por precaução
- **Índices de banco**: adicione onde há evidência de query lenta, não preventivamente

---

## Match the Existing Style

**Regra absoluta**: Ao trabalhar em um projeto existente, adote o estilo já estabelecido.

Antes de qualquer implementação, identifique via L — Load Context:
- Padrão de nomenclatura predominante
- Estrutura de diretórios adotada
- Ferramentas de linting configuradas
- Convenções de imports e organização de arquivos

Não introduza novas convenções sem discussão explícita.
