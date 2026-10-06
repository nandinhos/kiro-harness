# 🛡️ Safety Gate — Rigores por Ambiente

## Identificação Obrigatória de Ambiente

**Antes de propor código, alterar arquivos ou executar comandos**, categorize formalmente o Ambiente de Execução em `OBSERVED`:

| Ambiente | Evidência | Política | Ações Destrutivas |
|---|---|:---:|---|
| **`DEV` / `TEST`** | Branch `dev/*`, `APP_ENV=local/testing`, `.env` local | 🟢 **`ALLOW`** | Permitidas com salvaguarda de backup local. Bloqueio absoluto para destruição de SO (`rm -rf /`). |
| **`HOMOLOGACAO`** | Branch `staging/homolog`, `APP_ENV=staging` | 🟡 **`ASK (2 Alertas)`** | Confirmação em 2 etapas obrigatória. |
| **`PRODUCAO`** | Branch `main/master`, `APP_ENV=production` | 🔴 **`DENY`** | **FORA DE COGITAÇÃO** — bloqueio absoluto. |

---

## Matriz Granular por Tipo de Operação

### Banco de Dados & Migrações
- `migrate:fresh`, `db:wipe`, `DROP TABLE`, `TRUNCATE` → `ALLOW (aviso)` em DEV; `ASK 2x` em HML; `DENY` em PRD.

### Controle de Versão (Git)
- `git reset --hard`, `git clean -f`, `git push --force` → `ALLOW` em DEV; `ASK 2x` em HML; `DENY` em PRD.
- **Git push em projetos com CI**: Em repositórios com esteira de CI (`.github/workflows/` ou similar), é proibido fazer push sem que a suíte de testes esteja 100% verde no commit local.

### Filesystem
- `rm -rf <dir>` → `ALLOW` para cache/build em DEV; `ASK 2x` em HML; `DENY` em PRD.

### Infraestrutura & Nuvem
- `terraform destroy`, `kubectl delete`, etc. → `ASK 2x` em HML; `DENY` em PRD.

---

## Protocolo de 2 Alertas (HOMOLOGACAO)

Quando uma ação destrutiva é solicitada em ambiente de homologação:

**Alerta 1/2 [Impacto]**: Descrever o blast radius no ambiente compartilhado e solicitar confirmação explícita.

**Alerta 2/2 [Backup & Rollback]**: Verificar se o backup foi executado e se existe estratégia de rollback imediato antes de prosseguir.

---

## Estratégias Canônicas de Branches

**Modo Enterprise (3 branches)**: `dev` → `staging` → `main`
- `dev`: desenvolvimento com liberdade total (ALLOW)
- `staging`: homologação com confirmação (ASK 2x)
- `main`: produção, somente merges (DENY para destrutivos)

**Modo Clássico (2 branches)**: `dev` → `main`
- `dev`: desenvolvimento ágil (ALLOW)
- `main`: produção (DENY para destrutivos)
