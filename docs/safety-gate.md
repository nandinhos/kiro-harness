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
