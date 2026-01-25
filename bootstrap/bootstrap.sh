#!/usr/bin/env bash

set -e

echo "🚀 Dev Setup - Unix"

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" &> /dev/null; then
    echo "✅ $cmd"
    return 0
  fi
  echo "⚠️  $cmd não encontrado"
  return 1
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v brew &> /dev/null; then
    echo "📦 Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
else
  if ! command -v curl &> /dev/null; then
    echo "📦 Instalando curl..."
    sudo apt update
    sudo apt install -y curl
  fi
fi

if ! command -v node &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install node
  else
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install nodejs -y
  fi
fi

if ! command -v git &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install git
  else
    sudo apt install git -y
  fi
fi

if ! command -v code &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask visual-studio-code
  else
    sudo snap install code --classic
  fi
fi

REPO_RAW_BASE="https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
TMP_DIR="$(mktemp -d -t dev-setup-XXXXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ "$SETUP_TERMINAL" == "true" ]]; then
  mkdir -p "$TMP_DIR/terminal"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    curl -fsSL "$REPO_RAW_BASE/terminal/macos.sh" -o "$TMP_DIR/terminal/macos.sh"
    chmod +x "$TMP_DIR/terminal/macos.sh"
    bash "$TMP_DIR/terminal/macos.sh"
  else
    curl -fsSL "$REPO_RAW_BASE/terminal/linux.sh" -o "$TMP_DIR/terminal/linux.sh"
    chmod +x "$TMP_DIR/terminal/linux.sh"
    bash "$TMP_DIR/terminal/linux.sh"
  fi
fi

mkdir -p "$TMP_DIR/vscode"
curl -fsSL "$REPO_RAW_BASE/vscode/setup.js" -o "$TMP_DIR/vscode/setup.js"
curl -fsSL "$REPO_RAW_BASE/vscode/settings.json" -o "$TMP_DIR/vscode/settings.json"
cd "$TMP_DIR/vscode"
node setup.js

echo "----------------------------------------"
echo "🔎 Verificando instalações"
check_cmd node || true
check_cmd git || true
check_cmd code || echo "ℹ️  Pode ser necessário reiniciar o terminal para o comando 'code' aparecer." 
if [[ "$SETUP_TERMINAL" == "true" ]]; then
  check_cmd neofetch || true
  check_cmd oh-my-posh || true
fi

echo "✅ Setup concluído"
