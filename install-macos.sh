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

BASE="$HOME/dev-setup"
git clone https://github.com/fernandohaeser/dev-setup "$BASE" 2>/dev/null || true

if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  echo "🖥️ Configurando terminal..."
  bash "$BASE/terminal/macos.sh"
fi

echo "🧠 Configurando VS Code..."
cd "$BASE/vscode"
node setup.js

echo "========================================"
echo "✅ Setup concluído! Reinicie o terminal."
echo "========================================"
