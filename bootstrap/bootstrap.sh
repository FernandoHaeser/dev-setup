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
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  CYAN="$(tput setaf 6)"
else
  BOLD=""; DIM=""; RESET=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""
fi

hr() { echo "${DIM}----------------------------------------${RESET}"; }
header() {
  local platform="Unix"
  [[ "$OSTYPE" == "darwin"* ]] && platform="macOS"
  echo "${BOLD}${BLUE}Dev Setup${RESET}${DIM} · ${platform}${RESET}"
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

if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v brew &> /dev/null; then
    step "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
else
  if ! command -v curl &> /dev/null; then
    step "Instalando curl..."
    sudo apt update
    sudo apt install -y curl
  fi
fi

if ! command -v node &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    step "Instalando Node.js (LTS)..."
    brew install node
  else
    step "Instalando Node.js (LTS)..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install nodejs -y
  fi
fi

if ! command -v git &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    step "Instalando Git..."
    brew install git
  else
    step "Instalando Git..."
    sudo apt install git -y
  fi
fi

if ! command -v code &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    step "Instalando VS Code..."
    brew install --cask visual-studio-code
  else
    step "Instalando VS Code..."
    sudo snap install code --classic
  fi
fi

REPO_RAW_BASE="https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
TMP_DIR="$(mktemp -d -t dev-setup-XXXXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

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
check_cmd code || info "Pode ser necessário reiniciar o terminal para o comando 'code' aparecer."

hr
ok "Setup concluído"
