#!/usr/bin/env bash
set -e

echo "========================================"
echo "🚀 Dev Setup - Inicialização (Linux)"
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

echo "📦 Atualizando pacotes do sistema..."
sudo apt update
sudo apt upgrade -y

if ! command -v curl &> /dev/null; then
  echo "📦 Instalando curl..."
  sudo apt install -y curl
fi

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

  # Garante que binários instalados em ~/.local/bin sejam detectados na mesma sessão
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "🧠 Configurando VS Code..."
mkdir -p "$TMP_DIR/vscode"
curl -fsSL "$REPO_RAW_BASE/vscode/setup.js" -o "$TMP_DIR/vscode/setup.js"
curl -fsSL "$REPO_RAW_BASE/vscode/settings.json" -o "$TMP_DIR/vscode/settings.json"
cd "$TMP_DIR/vscode"
node setup.js

echo "----------------------------------------"
echo "🔎 Verificando instalações"
check_cmd node || true
check_cmd git || true
check_cmd code || echo "ℹ️  Se o VS Code acabou de ser instalado, pode ser necessário reiniciar o terminal para o comando 'code' aparecer." 
if [[ "$INSTALL_TERMINAL" == "s" ]]; then
  check_cmd zsh || true
  check_cmd terminator || true
  check_cmd nvim || true
  check_cmd fastfetch || true
  echo "ℹ️  O Terminator foi configurado para usar 'FiraCode Nerd Font 11'. Reinicie o terminal para carregar a fonte e o zsh."
fi

echo "========================================"
echo "✅ Setup concluído! Reinicie o terminal."
echo "========================================"
