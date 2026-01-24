#!/usr/bin/env bash
set -e

echo "========================================"
echo "🚀 Dev Setup - Inicialização (macOS)"
echo "========================================"

read -p "Deseja instalar/configurar o TERMINAL? (s/n): " INSTALL_TERMINAL
INSTALL_TERMINAL=$(echo "$INSTALL_TERMINAL" | tr '[:upper:]' '[:lower:]')

if ! command -v brew &> /dev/null; then
  echo "📦 Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v node &> /dev/null; then
  brew install node
fi

if ! command -v git &> /dev/null; then
  brew install git
fi

if ! command -v code &> /dev/null; then
  brew install --cask visual-studio-code
fi

REPO_RAW_BASE="https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
TMP_DIR="$(mktemp -d -t dev-setup-XXXXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  echo "🖥️ Configurando terminal..."
  mkdir -p "$TMP_DIR/terminal"
  curl -fsSL "$REPO_RAW_BASE/terminal/macos.sh" -o "$TMP_DIR/terminal/macos.sh"
  chmod +x "$TMP_DIR/terminal/macos.sh"
  bash "$TMP_DIR/terminal/macos.sh"
fi

echo "🧠 Configurando VS Code..."
mkdir -p "$TMP_DIR/vscode"
curl -fsSL "$REPO_RAW_BASE/vscode/setup.js" -o "$TMP_DIR/vscode/setup.js"
curl -fsSL "$REPO_RAW_BASE/vscode/settings.json" -o "$TMP_DIR/vscode/settings.json"
cd "$TMP_DIR/vscode"
node setup.js

echo "========================================"
echo "✅ Setup concluído! Reinicie o terminal."
echo "========================================"
