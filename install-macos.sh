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
  echo "${BOLD}${BLUE}Dev Setup${RESET}${DIM} · macOS${RESET}"
  hr
}
step() { echo "${CYAN}▶${RESET} $*"; }
ok() { echo "${GREEN}✅${RESET} $*"; }
warn() { echo "${YELLOW}⚠️${RESET}  $*"; }
info() { echo "${DIM}ℹ️${RESET}  $*"; }

header

prompt_terminal_choice() {
  local answer=""

  if [[ -n "${DEV_SETUP_TERMINAL:-}" ]]; then
    answer="$DEV_SETUP_TERMINAL"
  elif [[ -t 0 ]]; then
    read -r -p "Deseja instalar/configurar o TERMINAL? (s/n): " answer
  elif [[ -r /dev/tty ]]; then
    read -r -p "Deseja instalar/configurar o TERMINAL? (s/n): " answer < /dev/tty
  else
    answer="n"
  fi

  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
  [[ "$answer" == "s" || "$answer" == "sim" || "$answer" == "y" || "$answer" == "yes" ]]
}

INSTALL_TERMINAL="n"
if prompt_terminal_choice; then
  INSTALL_TERMINAL="s"
fi

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" &> /dev/null; then
    ok "$cmd"
    return 0
  fi
  warn "$cmd não encontrado"
  return 1
}

if ! command -v brew &> /dev/null; then
  step "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v node &> /dev/null; then
  step "Instalando Node.js (LTS)..."
  brew install node
fi

if ! command -v git &> /dev/null; then
  step "Instalando Git..."
  brew install git
fi

if ! command -v code &> /dev/null; then
  step "Instalando VS Code..."
  brew install --cask visual-studio-code
fi

REPO_RAW_BASE="https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
TMP_DIR="$(mktemp -d -t dev-setup-XXXXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  step "Configurando terminal..."
  mkdir -p "$TMP_DIR/terminal"
  curl -fsSL "$REPO_RAW_BASE/terminal/macos.sh" -o "$TMP_DIR/terminal/macos.sh"
  chmod +x "$TMP_DIR/terminal/macos.sh"
  bash "$TMP_DIR/terminal/macos.sh"
fi

step "Configurando VS Code (extensões + settings)..."
mkdir -p "$TMP_DIR/vscode"
curl -fsSL "$REPO_RAW_BASE/vscode/setup.js" -o "$TMP_DIR/vscode/setup.js"
curl -fsSL "$REPO_RAW_BASE/vscode/settings.json" -o "$TMP_DIR/vscode/settings.json"
cd "$TMP_DIR/vscode"
node setup.js

hr
step "Verificando instalações"
check_cmd brew || true
check_cmd node || true
check_cmd git || true
check_cmd code || info "Se o VS Code acabou de ser instalado, pode ser necessário reiniciar o terminal para o comando 'code' aparecer."
if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  check_cmd zsh || true
  check_cmd fastfetch || true
fi

hr
ok "Setup concluído! Feche e reabra o terminal."
