#!/usr/bin/env bash
# install-mac.sh - Instalador de software educativo para macOS / Educational software installer for macOS
# Tiendas soportadas: Homebrew (fórmulas y casks), MacPorts, Nix, mas (Mac App Store) y descarga directa.
set -uo pipefail

VERSION="1.0.0"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG="$ROOT/catalog/packages.tsv"
APPS="$ROOT/catalog/apps.tsv"

DRY_RUN=0
ALL_STORES=0
ASSUME_YES=0
GROUP="core"
STORES_REQUESTED=""
LIST_STORES=""
MAS_IDS="${MAS_IDS:-}"

log()  { printf '\033[1;36m[soft_ed]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[aviso]\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }
run()  { if [ "$DRY_RUN" -eq 1 ]; then printf '  DRY: %s\n' "$*"; return 0; fi; "$@"; }

usage() {
  cat <<'EOF'
Uso / Usage: ./install-mac.sh [opciones]

  --dry-run              Ver qué se instalaría / Preview only
  --all-stores           Usar todas las tiendas detectadas / All detected stores
  --stores LISTA         p. ej. brew,cask,macports,nix,mas,direct
  --group core|extra|all  Grupo del catálogo (por defecto core)
  --mas-ids ID,ID        IDs de Mac App Store a instalar con 'mas'
  --yes                  Sin preguntas / Non-interactive
  --list-stores          Listar tiendas detectadas
  --help                 Esta ayuda

Ejemplos:
  ./install-mac.sh --dry-run
  ./install-mac.sh --stores brew,cask --group all --yes
  MAS_IDS=1258173924 ./install-mac.sh --stores mas
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --all-stores) ALL_STORES=1 ;;
    --stores) STORES_REQUESTED="${2:-}"; shift ;;
    --group) GROUP="${2:-core}"; shift ;;
    --mas-ids) MAS_IDS="${2:-}"; shift ;;
    --yes|-y) ASSUME_YES=1 ;;
    --list-stores) LIST_STORES=1 ;;
    --help|-h) usage; exit 0 ;;
    *) err "Opción desconocida: $1"; usage; exit 2 ;;
  esac
  shift
done

[ -r "$CATALOG" ] && [ -r "$APPS" ] || { err "Falta el catálogo en $ROOT"; exit 1; }
case "$GROUP" in core|extra|all) ;; *) err "Grupo inválido: $GROUP"; exit 2 ;; esac

declare -A STORE_CMD=()
AVAILABLE=()
for pair in "brew:brew" "cask:brew" "macports:port" "nix:nix" "mas:mas" "direct:curl"; do
  s="${pair%%:*}"; c="${pair##*:}"
  if command -v "$c" >/dev/null 2>&1; then AVAILABLE+=("$s"); STORE_CMD["$s"]="$c"; fi
done

if [ "$LIST_STORES" -eq 1 ]; then
  printf 'Tiendas detectadas: %s\n' "${AVAILABLE[*]:-ninguna}"
  exit 0
fi
[ "${#AVAILABLE[@]}" -gt 0 ] || { err "No se detectó Homebrew, MacPorts, Nix, mas ni curl"; exit 1; }
log "Tiendas detectadas: ${AVAILABLE[*]}"

SELECTED=()
if [ -n "$STORES_REQUESTED" ]; then
  IFS=',' read -r -a wanted <<< "$STORES_REQUESTED"
  for w in "${wanted[@]}"; do
    w="$(echo "$w" | tr -d '[:space:]')"
    [ -n "${STORE_CMD[$w]:-}" ] && SELECTED+=("$w") || warn "'$w' no disponible"
  done
elif [ "$ALL_STORES" -eq 1 ]; then
  SELECTED=("${AVAILABLE[@]}")
else
  for s in brew cask macports nix mas direct; do
    [ -n "${STORE_CMD[$s]:-}" ] && SELECTED+=("$s")
  done
fi

declare -A ALLOWED=()
while IFS=$'\t' read -r key name area tier; do
  case "${key:-}" in ''|'#'*) continue ;; esac
  if [ "$GROUP" = all ] || [ "${tier:-}" = "$GROUP" ]; then ALLOWED["$key"]=1; fi
done < "$APPS"

declare -A DONE_KEYS=()
TOTAL=0
ERRORS=0

confirm() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  [ "$DRY_RUN" -eq 1 ] && return 0
  printf '%s [s/N] ' "$1"; read -r answer || return 1
  case "$answer" in s|S|si|SI|y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

collect() { awk -F'\t' -v s="$1" '!/^#/ && NF>=3 && $1==s {print $2 "\t" $3}' "$CATALOG"; }

install_store() {
  local store="$1" key pkg p rc=0
  local -a keys=() pkgs=()
  while IFS=$'\t' read -r key pkg; do
    [ -n "${ALLOWED[$key]:-}" ] || continue
    [ -n "${DONE_KEYS[$key]:-}" ] && continue
    keys+=("$key"); pkgs+=("$pkg")
  done < <(collect "$store")

  [ "${#pkgs[@]}" -gt 0 ] || { log "$store: sin paquetes nuevos"; return 0; }
  log "$store: ${#pkgs[@]} paquete(s) -> ${pkgs[*]}"
  confirm "  ¿Continuar con $store?" || { warn "$store: omitido"; return 0; }

  case "$store" in
    brew)
      local -a formulas=()
      for p in "${pkgs[@]}"; do case "$p" in *-cask) ;; *) formulas+=("$p") ;; esac; done
      [ "${#formulas[@]}" -gt 0 ] && { run brew update || rc=1; run brew install "${formulas[@]}" || rc=1; } ;;
    cask)
      local -a casks=()
      for p in "${pkgs[@]}"; do case "$p" in *-cask) casks+=("${p%-cask}") ;; *) casks+=("$p") ;; esac; done
      run brew install --cask "${casks[@]}" || rc=1 ;;
    macports)
      if [ -n "$SUDO_MAC" ]; then run "$SUDO_MAC" port selfupdate || true; else run port selfupdate || true; fi
      if [ -n "$SUDO_MAC" ]; then run "$SUDO_MAC" port install "${pkgs[@]}" || rc=1; else run port install "${pkgs[@]}" || rc=1; fi ;;
    nix)
      for p in "${pkgs[@]}"; do run nix profile install "nixpkgs#$p" || run nix-env -iA "nixpkgs.$p" || rc=1; done ;;
    mas)
      if [ -z "$MAS_IDS" ]; then
        warn "Sin IDs: usa --mas-ids ID,ID o MAS_IDS=ID,ID"
        return 0
      fi
      local -a ids=(); IFS=',' read -r -a ids <<< "$MAS_IDS"
      for p in "${ids[@]}"; do run mas install "$p" || rc=1; done ;;
    direct)
      warn "Descarga directa: define APPS_URLS='url1,url2' para instalar .dmg/.pkg manualmente"
      if [ -n "${APPS_URLS:-}" ]; then
        local -a urls=(); IFS=',' read -r -a urls <<< "$APPS_URLS"
        local u dest
        for u in "${urls[@]}"; do
          dest="$HOME/Downloads/$(basename "$u")"
          if [ "$DRY_RUN" -eq 1 ]; then printf '  DRY: descargar %s\n' "$u"; else curl -fL -o "$dest" "$u" || rc=1; fi
        done
      fi ;;
  esac

  if [ "$rc" -eq 0 ]; then
    for k in "${keys[@]}"; do DONE_KEYS["$k"]=1; done
    TOTAL=$((TOTAL+${#keys[@]}))
  else
    err "$store: falló; se continúa con las demás tiendas"
    ERRORS=$((ERRORS+1))
  fi
}

SUDO_MAC=""
[ "$(id -u)" -eq 0 ] || SUDO_MAC="sudo"
for s in "${SELECTED[@]}"; do install_store "$s"; done

echo
log "Resumen: ${TOTAL} aplicación(es) procesadas; tiendas con errores: ${ERRORS}"
log "Tiendas detectadas: ${AVAILABLE[*]}"
exit 0
