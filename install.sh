#!/usr/bin/env bash
# install.sh - Instalador de software educativo para Linux / Educational software installer for Linux
# Soporta todas las tiendas/gestores habituales: apt, dnf/yum, zypper, pacman/AUR, apk,
# emerge, xbps, eopkg, slackpkg/slpkg, pkcon, flatpak, snap, nix, guix, brew y AppImage.
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
LIST_STORES=0

SUDO=""
[ "$(id -u)" -eq 0 ] || SUDO="sudo"

log()  { printf '\033[1;36m[soft_ed]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[aviso]\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }
run()  { if [ "$DRY_RUN" -eq 1 ]; then printf '  DRY: %s\n' "$*"; return 0; fi; "$@"; }

usage() {
  cat <<'EOF'
Uso / Usage: ./install.sh [opciones]

  --dry-run             Mostrar qué se instalaría sin instalar / Preview only
  --all-stores          Usar TODAS las tiendas detectadas / Use every detected store
  --stores LISTA        Tiendas concretas, p. ej. apt,flatpak,snap / Comma-separated
  --group core|extra|all  Grupo del catálogo (por defecto core) / Catalog tier
  --yes                 No preguntar confirmación / Non-interactive
  --list-stores         Listar tiendas detectadas y salir / List detected stores
  --help                Esta ayuda / This help

Ejemplos / Examples:
  ./install.sh --dry-run
  ./install.sh --all-stores --group all
  ./install.sh --stores apt,flatpak,snap --yes
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --all-stores) ALL_STORES=1 ;;
    --stores) STORES_REQUESTED="${2:-}"; shift ;;
    --group) GROUP="${2:-core}"; shift ;;
    --yes|-y) ASSUME_YES=1 ;;
    --list-stores) LIST_STORES=1 ;;
    --help|-h) usage; exit 0 ;;
    *) err "Opción desconocida / unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

[ -r "$CATALOG" ] || { err "No se encuentra $CATALOG"; exit 1; }
[ -r "$APPS" ] || { err "No se encuentra $APPS"; exit 1; }

case "$GROUP" in core|extra|all) ;; *) err "Grupo inválido: $GROUP"; exit 2 ;; esac

# ---------------------------------------------------------------- detección
declare -A STORE_CMD=()
AVAILABLE=()
ALL_STORES_ORDER=(apt dnf yum zypper pacman aur apk emerge xbps eopkg slackpkg slpkg pkcon flatpak snap nix guix brew appimage)

detect_cmd() {
  case "$1" in
    apt) printf 'apt-get' ;;
    dnf) printf 'dnf' ;;
    yum) printf 'yum' ;;
    zypper) printf 'zypper' ;;
    pacman) printf 'pacman' ;;
    aur) command -v yay 2>/dev/null || command -v paru 2>/dev/null || true ;;
    apk) printf 'apk' ;;
    emerge) printf 'emerge' ;;
    xbps) printf 'xbps-install' ;;
    eopkg) printf 'eopkg' ;;
    slackpkg) printf 'slackpkg' ;;
    slpkg) printf 'slpkg' ;;
    pkcon) printf 'pkcon' ;;
    flatpak) printf 'flatpak' ;;
    snap) printf 'snap' ;;
    nix) printf 'nix' ;;
    guix) printf 'guix' ;;
    brew) printf 'brew' ;;
    appimage) command -v curl 2>/dev/null || command -v wget 2>/dev/null || true ;;
  esac
}

for s in "${ALL_STORES_ORDER[@]}"; do
  c="$(detect_cmd "$s")"
  if [ -n "$c" ] && command -v "$c" >/dev/null 2>&1; then
    AVAILABLE+=("$s")
    STORE_CMD["$s"]="$c"
  fi
done

if [ "$LIST_STORES" -eq 1 ]; then
  printf 'Tiendas detectadas / detected stores: %s\n' "${AVAILABLE[*]:-ninguna/none}"
  exit 0
fi

if [ "${#AVAILABLE[@]}" -eq 0 ]; then
  err "No se detectó ninguna tienda soportada / No supported package store found"
  exit 1
fi

log "Tiendas detectadas: ${AVAILABLE[*]}"

# ---------------------------------------------------------------- selección
SELECTED=()
if [ -n "$STORES_REQUESTED" ]; then
  IFS=',' read -r -a wanted <<< "$STORES_REQUESTED"
  for w in "${wanted[@]}"; do
    w="$(echo "$w" | tr -d '[:space:]')"
    [ -z "$w" ] && continue
    if [ -n "${STORE_CMD[$w]:-}" ]; then
      SELECTED+=("$w")
    else
      warn "La tienda '$w' no está disponible, se omite / store not available"
    fi
  done
elif [ "$ALL_STORES" -eq 1 ]; then
  SELECTED=("${AVAILABLE[@]}")
else
  # Por defecto: la tienda nativa de la distro + universales (para lo que falte).
  for s in apt dnf yum zypper pacman apk emerge xbps eopkg slackpkg slpkg; do
    if [ -n "${STORE_CMD[$s]:-}" ]; then SELECTED+=("$s"); break; fi
  done
  for s in aur flatpak snap nix guix brew appimage pkcon; do
    [ -n "${STORE_CMD[$s]:-}" ] && SELECTED+=("$s")
  done
fi

[ "${#SELECTED[@]}" -gt 0 ] || { err "No hay tiendas seleccionadas"; exit 1; }
log "Tiendas seleccionadas: ${SELECTED[*]}"

# ---------------------------------------------------------------- catálogo
declare -A ALLOWED=()
while IFS=$'\t' read -r key name area tier; do
  case "${key:-}" in ''|'#'*) continue ;; esac
  if [ "$GROUP" = all ] || [ "${tier:-}" = "$GROUP" ]; then ALLOWED["$key"]=1; fi
done < "$APPS"

declare -A DONE_KEYS=()
TOTAL_ADD=0
FAILED_STORES=0

collect() {
  local store="$1"
  awk -F'\t' -v s="$store" '!/^#/ && NF>=3 && $1==s {print $2 "\t" $3}' "$CATALOG"
}

confirm() {
  local msg="$1"
  [ "$ASSUME_YES" -eq 1 ] && return 0
  [ "$DRY_RUN" -eq 1 ] && return 0
  printf '%s [s/N] ' "$msg"
  read -r answer || return 1
  case "$answer" in s|S|si|SI|Si|y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

count_for() {
  local store="$1" n=0 key pkg
  while IFS=$'\t' read -r key pkg; do
    [ -n "${ALLOWED[$key]:-}" ] || continue
    [ -n "${DONE_KEYS[$key]:-}" ] && continue
    n=$((n+1))
  done < <(collect "$store")
  printf '%s' "$n"
}

install_store() {
  local store="$1"
  local -a pkgs=() keys=()
  local key pkg
  while IFS=$'\t' read -r key pkg; do
    [ -n "${ALLOWED[$key]:-}" ] || continue
    [ -n "${DONE_KEYS[$key]:-}" ] && continue
    keys+=("$key"); pkgs+=("$pkg")
  done < <(collect "$store")

  if [ "${#pkgs[@]}" -eq 0 ]; then
    log "$store: sin paquetes nuevos en el catálogo / no new packages"
    return 0
  fi

  log "$store: ${#pkgs[@]} paquete(s) -> ${pkgs[*]}"
  confirm "  ¿Continuar con $store?" || { warn "$store: omitido por el usuario"; return 0; }

  local rc=0 cmd="${STORE_CMD[$store]}"
  case "$store" in
    apt)
      run $SUDO apt-get update -qq || rc=1
      [ "$rc" -eq 0 ] && run $SUDO apt-get install -y -- "${pkgs[@]}" || rc=1 ;;
    dnf)   run $SUDO dnf -y install "${pkgs[@]}" || rc=1 ;;
    yum)   run $SUDO yum -y install "${pkgs[@]}" || rc=1 ;;
    zypper) run $SUDO zypper --non-interactive install "${pkgs[@]}" || rc=1 ;;
    pacman) run $SUDO pacman -S --noconfirm --needed "${pkgs[@]}" || rc=1 ;;
    aur)   run "$cmd" -S --noconfirm --needed "${pkgs[@]}" || rc=1 ;;
    apk)   run $SUDO apk add "${pkgs[@]}" || rc=1 ;;
    emerge) run $SUDO emerge --ask=n "${pkgs[@]}" || rc=1 ;;
    xbps)  run $SUDO xbps-install -Suy "${pkgs[@]}" || rc=1 ;;
    eopkg) run $SUDO eopkg install -y "${pkgs[@]}" || rc=1 ;;
    slackpkg) run $SUDO slackpkg install "${pkgs[@]}" || rc=1 ;;
    slpkg) for p in "${pkgs[@]}"; do run $SUDO slpkg -s sbo "$p" || rc=1; done ;;
    pkcon) run pkcon install -y "${pkgs[@]}" || rc=1 ;;
    flatpak)
      run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || rc=1
      [ "$rc" -eq 0 ] && run flatpak install -y flathub "${pkgs[@]}" || rc=1 ;;
    snap)  for p in "${pkgs[@]}"; do run $SUDO snap install "$p" || rc=1; done ;;
    nix)
      for p in "${pkgs[@]}"; do
        run nix profile install "nixpkgs#$p" || run nix-env -iA "nixpkgs.$p" || rc=1
      done ;;
    guix)  run guix install "${pkgs[@]}" || rc=1 ;;
    brew)
      local -a formulas=() casks=() p
      for p in "${pkgs[@]}"; do
        case "$p" in *-cask) casks+=("${p%-cask}") ;; *) formulas+=("$p") ;; esac
      done
      [ "${#formulas[@]}" -gt 0 ] && { run "$cmd" install "${formulas[@]}" || rc=1; }
      [ "${#casks[@]}" -gt 0 ] && { run "$cmd" install --cask "${casks[@]}" || rc=1; } ;;
    appimage)
      warn "AppImage: define URLs en catalog/packages.tsv (store=appimage, key|url|nombre) o APPIMAGE_URLS"
      if [ -n "${APPIMAGE_URLS:-}" ]; then
        local -a urls=(); IFS=',' read -r -a urls <<< "$APPIMAGE_URLS"
        local u dest
        for u in "${urls[@]}"; do
          dest="$HOME/.local/bin/$(basename "$u")"
          run mkdir -p "$HOME/.local/bin"
          if [ "$DRY_RUN" -eq 1 ]; then
            printf '  DRY: descargar %s -> %s\n' "$u" "$dest"
          elif command -v curl >/dev/null 2>&1; then
            curl -fL --retry 2 -o "$dest" "$u" && chmod +x "$dest" || rc=1
          elif command -v wget >/dev/null 2>&1; then
            wget -O "$dest" "$u" && chmod +x "$dest" || rc=1
          fi
        done
      fi ;;
  esac

  if [ "$rc" -eq 0 ]; then
    for k in "${keys[@]}"; do DONE_KEYS["$k"]=1; done
    TOTAL_ADD=$((TOTAL_ADD+${#keys[@]}))
  else
    err "$store: falló la instalación; se continúa con las demás tiendas"
    FAILED_STORES=$((FAILED_STORES+1))
  fi
}

for s in "${SELECTED[@]}"; do install_store "$s"; done

echo
log "Resumen: ${TOTAL_ADD} aplicación(es) procesadas; tiendas con errores: ${FAILED_STORES}"
log "Tiendas detectadas: ${AVAILABLE[*]}"
if [ "$FAILED_STORES" -gt 0 ]; then
  warn "Algunos paquetes no existen en esta distro/tienda. Prueba --stores con otra tienda o --all-stores."
fi
exit 0
