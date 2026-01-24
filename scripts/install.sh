#!/usr/bin/env bash
set -e

echo "========================================"
echo "🚀 Dev Setup - Inicialização (Linux)"
echo "========================================"

read -p "Deseja instalar/configurar o TERMINAL? (s/n): " INSTALL_TERMINAL
INSTALL_TERMINAL=$(echo "$INSTALL_TERMINAL" | tr '[:upper:]' '[:lower:]')

if ! command -v node &> /dev/null; then
  echo "📦 Instalando Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install nodejs -y
fi

if ! command -v git &> /dev/null; then
  echo "📦 Instalando Git..."
  sudo apt install git -y
fi

if ! command -v code &> /dev/null; then
  echo "📦 Instalando VS Code..."
  sudo snap install code --classic
fi

BASE="$HOME/dev-setup"
git clone https://github.com/fernandohaeser/dev-setup "$BASE" 2>/dev/null || true

if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  echo "🖥️ Configurando terminal..."
  bash "$BASE/terminal/linux.sh"
fi

echo "🧠 Configurando VS Code..."
cd "$BASE/vscode"
node setup.js

echo "========================================"
echo "✅ Setup concluído! Reinicie o terminal."
echo "========================================"
