#!/usr/bin/env bash
# safety-gate.sh — Núcleo de avaliação do Safety Gate do Kiro Harness (CEH).
#
# Avalia um comando shell candidato contra a política de ambiente e emite um veredicto.
#
# Uso:
#   echo "<comando>" | safety-gate.sh         # lê o comando do stdin
#   safety-gate.sh "<comando>"                # ou como argumento
#
# Saída (stdout): VEREDICTO em uma linha — ALLOW | ASK | DENY
# Saída (stderr): justificativa legível quando ASK ou DENY.
# Exit code:
#   0  -> ALLOW (ou comando não-destrutivo)
#   10 -> ASK   (ação destrutiva em HOMOLOGACAO; exige confirmação humana)
#   20 -> DENY  (ação destrutiva em PRODUCAO, ou destruição catastrófica em qualquer ambiente)
#
# Princípio fail-safe: qualquer erro interno resulta em ALLOW (exit 0) — o gate
# jamais bloqueia por falha própria. Apenas DENY/ASK explícitos restringem.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read_command() {
  if [[ $# -gt 0 && -n "${1:-}" ]]; then
    printf '%s' "$1"
    return 0
  fi
  cat
}

# Remove prefixos de proxy/wrapper comuns para evitar evasão do gate.
normalize_command() {
  local cmd="$1"
  cmd="${cmd#"${cmd%%[![:space:]]*}"}" # ltrim
  # remove prefixos conhecidos repetidamente (sudo, env VAR=, time, nice,
  # wrappers de execução bash -c/sh -c/eval) para evitar evasão do gate.
  local changed=1
  while [[ $changed -eq 1 ]]; do
    changed=0
    case "$cmd" in
      sudo\ *) cmd="${cmd#sudo }"; changed=1 ;;
      time\ *) cmd="${cmd#time }"; changed=1 ;;
      nice\ *) cmd="${cmd#nice }"; changed=1 ;;
      env\ [A-Z_]*=*) cmd="${cmd#env }"; cmd="${cmd#*=* }"; changed=1 ;;
      bash\ -c\ *) cmd="${cmd#bash -c }"; changed=1 ;;
      sh\ -c\ *) cmd="${cmd#sh -c }"; changed=1 ;;
      zsh\ -c\ *) cmd="${cmd#zsh -c }"; changed=1 ;;
      eval\ *) cmd="${cmd#eval }"; changed=1 ;;
      xargs\ *) cmd="${cmd#xargs }"; changed=1 ;;
    esac
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"
  done
  # Neutraliza delimitadores de subshell e aspas, expondo o comando interno à
  # análise (ex.: `$(rm -rf /)`, backticks, `"rm -rf /"`). Como leaders read-only
  # (echo/grep/...) desarmam o próprio segmento, remover aspas não cria falso
  # negativo nos casos benignos do H2.
  # Conteúdo de subshell `$(...)`, backticks e process substitution `<(...)`/`>(...)`
  # é executado como comando próprio pelo shell — isola como segmento separado
  # (vira `;`) para avaliação isolada. Aspas e parênteses soltos viram espaço.
  # Usa sed porque `<(` em pattern-substitution de bash seria lido como process
  # substitution e quebraria o parsing do próprio script.
  cmd="$(printf '%s' "$cmd" | sed -E -e 's/\$\(/;/g' -e 's/[<>]\(/;/g' -e 's/`/;/g' -e 's/["'"'"'()]/ /g')"
  printf '%s' "$cmd"
}

# Comandos leitores/inspetores: quando o comando efetivamente executado é um
# destes, o restante da linha é tratado como DADO (string/argumento), não como
# comando executável. Evita falso positivo em `echo "DROP TABLE"`,
# `grep "rm -rf" script.sh`, `cat migrate:fresh.md`, etc. (achado H2).
is_readonly_leader() {
  local cmd="$1"
  [[ "$cmd" =~ ^(echo|printf|grep|egrep|fgrep|rg|cat|less|more|head|tail|awk|sed|ls|find[[:space:]].*-print|git[[:space:]]+(log|show|diff|status|grep)|jq)([[:space:]]|$) ]]
}

# Destruição catastrófica de SO — DENY em QUALQUER ambiente, inclusive DEV.
is_catastrophic() {
  local cmd="$1"
  is_readonly_leader "$cmd" && return 1
  # rm recursivo+força apontando para raiz / home / glob de raiz.
  # Cobre flags curtas (-rf, -fr, -r -f) E longas (--recursive --force).
  if is_rm_recursive_force "$cmd" && [[ "$cmd" =~ (^|[[:space:]])(/|~|/\*|\$HOME|--no-preserve-root)([[:space:]]|/|$) ]]; then
    return 0
  fi
  [[ "$cmd" =~ --no-preserve-root ]] && [[ "$cmd" =~ (^|[[:space:]]|/)rm([[:space:]]) ]] && return 0
  [[ "$cmd" =~ :\(\)\{ ]] && return 0
  [[ "$cmd" =~ dd[[:space:]]+.*of=/dev/(sd|nvme|hd|disk) ]] && return 0
  [[ "$cmd" =~ (^|[[:space:]])mkfs ]] && return 0
  [[ "$cmd" =~ \>[[:space:]]*/dev/(sd|nvme|hd) ]] && return 0
  return 1
}

# Detecta `rm` com recursão E força, independente de flags curtas ou longas,
# e independente de ser invocado por nome (`rm`) ou caminho absoluto (`/bin/rm`).
is_rm_recursive_force() {
  local cmd="$1"
  [[ "$cmd" =~ (^|[[:space:]]|/)rm([[:space:]]) ]] || return 1
  local recursive=1 force=1
  # flags curtas combinadas (-rf, -fr, -Rf) ou separadas (-r ... -f)
  [[ "$cmd" =~ (^|[[:space:]])-[a-zA-Z]*[rR][a-zA-Z]* ]] && recursive=0
  [[ "$cmd" =~ (^|[[:space:]])-[a-zA-Z]*f[a-zA-Z]* ]] && force=0
  # flags longas
  [[ "$cmd" =~ --recursive ]] && recursive=0
  [[ "$cmd" =~ --force ]] && force=0
  [[ $recursive -eq 0 && $force -eq 0 ]]
}

# Ações destrutivas sujeitas à política por ambiente.
is_destructive() {
  local cmd="$1"
  # Se o comando executado é um leitor/inspetor, o conteúdo é dado, não ação (H2).
  is_readonly_leader "$cmd" && return 1
  # filesystem: rm recursivo+força (curtas ou longas)
  is_rm_recursive_force "$cmd" && return 0
  # find ... -delete / -exec rm
  [[ "$cmd" =~ (^|[[:space:]])find([[:space:]]).*(-delete|-exec[[:space:]]+rm) ]] && return 0
  # truncate(1) zerando arquivo
  [[ "$cmd" =~ (^|[[:space:]])truncate([[:space:]]).*(-s|--size)[[:space:]]*0 ]] && return 0
  # git destrutivo
  [[ "$cmd" =~ git[[:space:]]+.*(reset[[:space:]]+--hard|clean[[:space:]]+-[a-zA-Z]*f|push[[:space:]]+.*--force|push[[:space:]]+.*-f([[:space:]]|$)|branch[[:space:]]+-D) ]] && return 0
  # banco de dados (SQL executável)
  [[ "$cmd" =~ (DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)|TRUNCATE[[:space:]]+(TABLE)?|DELETE[[:space:]]+FROM[[:space:]]) ]] && return 0
  # migrações destrutivas — ancoradas em início de token (H1)
  [[ "$cmd" =~ (^|[[:space:]])(migrate:fresh|migrate:reset|db:wipe|db:fresh)([[:space:]]|$|[^a-zA-Z0-9:._-]) ]] && return 0
  # containers / orquestração
  [[ "$cmd" =~ docker[[:space:]]+.*(system[[:space:]]+prune|volume[[:space:]]+(rm|prune)|rm[[:space:]]+-[a-zA-Z]*f|image[[:space:]]+prune) ]] && return 0
  [[ "$cmd" =~ (docker-compose|docker[[:space:]]+compose)[[:space:]]+.*down[[:space:]]+.*(-v|--volumes) ]] && return 0
  # infra
  [[ "$cmd" =~ (terraform[[:space:]]+destroy|kubectl[[:space:]]+delete) ]] && return 0
  return 1
}

# Expande atribuições de variáveis inline (ex.: `R=rf; rm -$R /`) substituindo
# usos de $VAR / ${VAR} pelos valores literais atribuídos no mesmo comando.
# Fecha a evasão por indireção de flag/argumento via variável. Best-effort:
# cobre atribuições simples sem aspas, suficientes para desarmar a ofuscação.
expand_inline_vars() {
  local cmd="$1" name val
  # Para cada atribuição NAME=valor encontrada, substitui os usos subsequentes.
  while [[ "$cmd" =~ (^|[[:space:]\;])([A-Za-z_][A-Za-z0-9_]*)=([^[:space:]\;\&\|]+) ]]; do
    name="${BASH_REMATCH[2]}"
    val="${BASH_REMATCH[3]}"
    # remove a atribuição já consumida para não repetir infinitamente
    cmd="${cmd/${name}=${val}/ }"
    # substitui ${NAME} e $NAME pelo valor literal
    cmd="${cmd//\$\{${name}\}/${val}}"
    cmd="${cmd//\$${name}/${val}}"
  done
  printf '%s' "$cmd"
}

main() {
  local raw cmd env
  raw="$(read_command "$@")" || { echo "ALLOW"; return 0; }

  # Fork bomb é detectado sobre o comando BRUTO, antes de qualquer normalização
  # (a neutralização de parênteses removeria o padrão `:(){`).
  if [[ "$raw" =~ :\(\)[[:space:]]*\{ || "$raw" =~ \{[[:space:]]*:\|: ]]; then
    echo "DENY"
    echo "[SAFETY GATE] Fork bomb detectada — bloqueada em qualquer ambiente." >&2
    return 20
  fi

  raw="$(expand_inline_vars "$raw")"
  cmd="$(normalize_command "$raw")" || cmd="$raw"

  # Avalia o comando SEGMENTO A SEGMENTO. Separadores de shell (&& || ; | &)
  # são substituídos por quebras de linha; cada segmento é julgado isoladamente.
  # Isso impede evasão via `echo x && rm -rf /` (achado C3): o leader read-only
  # só desarma o próprio segmento, não a linha inteira.
  local segments seg seg_norm worst_env worst=0
  segments="$(printf '%s' "$cmd" | sed -E 's/\|\||&&|;|\||&/\n/g')"

  worst_env="$("$SCRIPT_DIR/detect-env.sh" 2>/dev/null)" || worst_env="UNKNOWN"

  while IFS= read -r seg; do
    seg_norm="$(normalize_command "$seg")"
    [[ -z "$seg_norm" ]] && continue

    if is_catastrophic "$seg_norm"; then
      echo "DENY"
      echo "[SAFETY GATE] Comando de destruição catastrófica de SO bloqueado em qualquer ambiente: ${seg_norm:0:80}" >&2
      return 20
    fi

    if is_destructive "$seg_norm"; then
      case "$worst_env" in
        PRODUCAO)
          echo "DENY"
          echo "[SAFETY GATE] 🔴 PRODUCAO — ação destrutiva FORA DE COGITAÇÃO: ${seg_norm:0:80}" >&2
          return 20
          ;;
        HOMOLOGACAO)
          [[ $worst -lt 10 ]] && worst=10
          env="$seg_norm"
          ;;
        DEV | UNKNOWN | *)
          [[ $worst -lt 1 ]] && worst=1
          env="$seg_norm"
          ;;
      esac
    fi
  done <<<"$segments"

  case "$worst" in
    10)
      echo "ASK"
      echo "[SAFETY GATE] 🟡 HOMOLOGACAO — ação destrutiva exige confirmação em 2 alertas (impacto + backup/rollback): ${env:0:80}" >&2
      return 10
      ;;
    1)
      echo "ALLOW"
      echo "[SAFETY GATE] 🟢 DEV — ação destrutiva permitida com salvaguarda local: ${env:0:80}" >&2
      return 0
      ;;
    *)
      echo "ALLOW"
      return 0
      ;;
  esac
}

main "$@"
