#!/usr/bin/env bash
set -e

echo "========================================"
echo "🚀 Dev Setup - Inicialização (macOS)"
echo "========================================"

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
    echo "✅ $cmd"
    return 0
  fi
  echo "⚠️  $cmd não encontrado"
  return 1
}

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

echo "----------------------------------------"
echo "🔎 Verificando instalações"
check_cmd brew || true
check_cmd node || true
check_cmd git || true
check_cmd code || echo "ℹ️  Se o VS Code acabou de ser instalado, pode ser necessário reiniciar o terminal para o comando 'code' aparecer." 
if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  check_cmd zsh || true
  check_cmd neofetch || true
  check_cmd oh-my-posh || echo "ℹ️  O oh-my-posh pode exigir reinício do shell/PATH após instalar."
fi

echo "========================================"
echo "✅ Setup concluído! Reinicie o terminal."
echo "========================================"
