# 🛡️ Safety Gate — Guia Completo

O Safety Gate é o mecanismo de proteção por ambiente que governa quais operações são permitidas, requerem confirmação ou são bloqueadas.

---

## Os 3 Níveis

### 🟢 DEV / TEST — ALLOW

**Identificação** (em OBSERVED):
- Branch: `dev`, `dev/*`, `feature/*`, `fix/*`
- APP_ENV: `local`, `testing`, `development`
- Arquivo `.env` local presente

**Política**: Liberdade com salvaguarda. Operações destrutivas são permitidas com aviso de backup local.

**Exceções permanentes** (mesmo em DEV):
- `rm -rf /` ou qualquer remoção de sistema operacional
- Fork bombs e processos destrutivos irreversíveis do sistema

---

### 🟡 HOMOLOGACAO — ASK (2 Alertas)

**Identificação** (em OBSERVED):
- Branch: `staging`, `homolog`, `homologacao`, `hml`
- APP_ENV: `staging`, `homolog`

**Protocolo de 2 Alertas Obrigatórios**:

**Alerta 1/2 — Impacto no Ambiente Compartilhado:**
```
⚠️ ALERTA 1/2 [HOMOLOGACAO]: Esta operação afeta o ambiente de homologação compartilhado.
Blast radius: [descrição do impacto]
Confirme explicitamente para prosseguir.
```

**Alerta 2/2 — Backup e Rollback:**
```
⚠️ ALERTA 2/2 [HOMOLOGACAO — Backup & Rollback]:
O backup foi executado? Existe estratégia de rollback imediato?
Confirme que o backup está disponível antes de prosseguir.
```

---

### 🔴 PRODUCAO — DENY

**Identificação** (em OBSERVED):
- Branch: `main`, `master`, `production`, `prod`
- APP_ENV: `production`, `prod`

**Política**: FORA DE COGITAÇÃO. Bloqueio absoluto e incondicional para:
- Comandos destrutivos em banco (DROP, TRUNCATE, DELETE sem WHERE)
- `git push --force` em branches protegidas
- `rm -rf` em diretórios de dados
- `terraform destroy` sem pipeline de aprovação
- Qualquer operação com potencial de perda irreversível de dados

**Mensagem canônica de bloqueio:**
```
🔴 BLOQUEADO [PRODUCAO — FORA DE COGITAÇÃO]:
Esta operação é terminantemente proibida em ambiente de produção.
Para operações emergenciais em produção, consulte o runbook operacional.
```

---

## Detecção de Ambiente (Fallback)

Se nenhuma evidência explícita estiver disponível:

```bash
# Verificar branch atual
git branch --show-current

# Verificar APP_ENV
cat .env | grep APP_ENV

# Verificar CI/CD context
echo $GITHUB_REF $CI_COMMIT_REF_NAME $ENVIRONMENT
```

**Se UNKNOWN**: Adotar o nível mais restritivo identificável. Em caso de ambiguidade entre DEV e HML, tratar como HML.

---

## Exceções e Overrides

O Safety Gate não possui override. As únicas saídas são:
1. Confirmar nos alertas (HOMOLOGACAO)
2. Desistir da operação (PRODUCAO)
3. Recontextualizar a tarefa em ambiente adequado

---

## Implementação Executável

O Safety Gate é aplicado por código determinístico, não por julgamento do agente (ver ADR 003):

- `scripts/safety-gate.sh` — núcleo de avaliação. Lê o comando candidato, detecta o
  ambiente via `scripts/detect-env.sh`, e emite veredicto (`ALLOW`/`ASK`/`DENY`) com
  exit code (`0`/`10`/`20`).
- `.kiro/hooks/safety-gate.json` + `scripts/hooks/safety-gate-hook.sh` — adaptador que
  conecta o núcleo ao evento `PreToolUse` do Kiro (exit 2 bloqueia; JSON `ask` confirma).

### Resistência a evasão

O núcleo normaliza o comando antes de avaliar, cobrindo os seguintes vetores (todos com
cobertura de teste em `tests/test-safety-gate.sh`):

- Prefixos: `sudo`, `env VAR=`, `time`, `nice`.
- Wrappers de execução: `bash -c`, `sh -c`, `zsh -c`, `eval`, `xargs`.
- Flags curtas e longas de `rm`: `-rf`, `-fr`, `-r -f`, `--recursive --force`, `--no-preserve-root`.
- Chaining: `&&`, `||`, `;`, `|`, `&` — cada segmento é avaliado isoladamente.
- Subshell e process substitution: `$(...)`, backticks, `<(...)`, `>(...)` — isolados como segmentos próprios.
- Fork bomb: detectado sobre o comando bruto, antes da normalização.
- Leitores (`echo`, `grep`, `cat`, `git log`, …): o conteúdo citado é tratado como dado,
  não comando — mas apenas para o segmento que o leader encabeça.

### Limitações conhecidas (fail-closed)

Estas são decisões conscientes de projeto. O gate prioriza **bloquear a mais** (falso
positivo) a **bloquear a menos** (falso negativo), pois um falso negativo em comando
destrutivo é catastrófico, enquanto um falso positivo apenas gera uma confirmação extra.

- **Separador dentro de string literal**: `echo "a && rm -rf /"` é bloqueado, embora o
  `rm` seja apenas texto. O quote-stripping ocorre antes do split de segmentos, então
  separadores dentro de aspas são tratados como reais. Over-block aceitável.
- **Heurística de SQL**: a detecção de `DROP`/`DELETE`/`TRUNCATE` é por padrão textual,
  não por parsing de SQL. Pode gerar falso positivo em comandos que mencionem esses
  termos fora de um contexto executável não coberto pelos leaders conhecidos.
- **Payload despejado em interpretador via pipe**: `echo "<comando>" | sh` (ou `| bash`)
  não é bloqueado, pois o segmento `echo` é um leitor e o conteúdo é tratado como dado.
  O gate não decodifica o que um interpretador fará com stdin. Mitigação: o Pre-Push Gate
  e a revisão humana permanecem como camadas adicionais. Vetor conhecido e aceito;
  recomenda-se não desabilitar os demais tiers de proteção.
- **Ofuscação dinâmica em runtime**: construções cujo payload só existe após execução do
  shell — `echo <base64> | base64 -d | sh`, `CMD="rm -rf /"; eval $CMD` (string entre
  aspas atribuída a variável e avaliada) — não são resolvíveis por análise estática. O
  gate expande indireção simples de variável (`R=rf; rm -$R /` → bloqueado), mas não
  interpreta decodificação/eval de strings montadas em runtime. É um limite teórico da
  análise estática de shell. Mitigação: Pre-Push Gate, revisão humana e a confirmação de
  comando do próprio Kiro.

Novos vetores de evasão devem ser tratados como bug e acompanhados de teste de regressão.
