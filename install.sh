#!/usr/bin/env bash
set -e

supports_color() {
  [[ -t 1 ]] || return 1
  command -v tput >/dev/null 2>&1 || return 1
  [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]
}

if supports_color; then
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
  RESET="$(tput sgr0)"
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  CYAN="$(tput setaf 6)"
else
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""
fi

hr() { echo "${DIM}----------------------------------------${RESET}"; }
header() {
  echo "${BOLD}${BLUE}Dev Setup${RESET}${DIM} · Linux${RESET}"
  hr
}
step() { echo "${CYAN}▶${RESET} $*"; }
ok() { echo "${GREEN}✅${RESET} $*"; }
warn() { echo "${YELLOW}⚠️${RESET}  $*"; }
info() { echo "${DIM}ℹ️${RESET}  $*"; }

header

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" &> /dev/null; then
    ok "$cmd"
    return 0
  fi
  warn "$cmd não encontrado"
  return 1
}

step "Atualizando pacotes do sistema..."
sudo apt update
sudo apt upgrade -y

if ! command -v curl &> /dev/null; then
  step "Instalando curl..."
  sudo apt install -y curl
fi

if ! command -v node &> /dev/null; then
  step "Instalando Node.js (LTS)..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install nodejs -y
fi

if ! command -v git &> /dev/null; then
  step "Instalando Git..."
  sudo apt install git -y
fi

if ! command -v code &> /dev/null; then
  step "Instalando VS Code..."
  sudo snap install code --classic
fi

REPO_RAW_BASE="https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
TMP_DIR="$(mktemp -d -t dev-setup-XXXXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR" >/dev/null 2>&1 || true
}
step "Configurando VS Code (extensões + settings)..."
mkdir -p "$TMP_DIR/vscode"
curl -fsSL "$REPO_RAW_BASE/vscode/setup.js" -o "$TMP_DIR/vscode/setup.js"
curl -fsSL "$REPO_RAW_BASE/vscode/settings.json" -o "$TMP_DIR/vscode/settings.json"
cd "$TMP_DIR/vscode"
node setup.js

hr
step "Verificando instalações"
check_cmd node || true
check_cmd git || true
check_cmd code || info "Se o VS Code acabou de ser instalado, pode ser necessário reiniciar o terminal para o comando 'code' aparecer."

hr
ok "Setup concluído! Feche e reabra o terminal."
