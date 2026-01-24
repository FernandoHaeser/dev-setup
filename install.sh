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

REPO_RAW_BASE="https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
TMP_DIR="$(mktemp -d -t dev-setup-XXXXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  echo "🖥️ Configurando terminal..."
  mkdir -p "$TMP_DIR/terminal"
  curl -fsSL "$REPO_RAW_BASE/terminal/linux.sh" -o "$TMP_DIR/terminal/linux.sh"
  chmod +x "$TMP_DIR/terminal/linux.sh"
  bash "$TMP_DIR/terminal/linux.sh"
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
