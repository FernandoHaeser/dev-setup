#!/usr/bin/env bash

set -e

echo "🚀 Iniciando setup do terminal (Linux)"

sudo apt update

sudo apt install -y \
  zsh \
  curl \
  git \
  neofetch \
  fontconfig

LIST_TOOL=""
if command -v eza &> /dev/null; then
  LIST_TOOL="eza"
elif command -v exa &> /dev/null; then
  LIST_TOOL="exa"
else
  sudo apt install -y eza >/dev/null 2>&1 || sudo apt install -y exa >/dev/null 2>&1 || true
  if command -v eza &> /dev/null; then
    LIST_TOOL="eza"
  elif command -v exa &> /dev/null; then
    LIST_TOOL="exa"
  fi
fi

mkdir -p "$HOME/.local/bin"

if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
fi

THEME_DIR="$HOME/.config/oh-my-posh"
mkdir -p "$THEME_DIR"
curl -fsSL "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json" \
  -o "$THEME_DIR/jandedobbeleer.omp.json"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

curl -fLo "$FONT_DIR/FiraCodeNerdFont-Regular.ttf" \
https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf

fc-cache -fv

cat << 'EOF' > ~/.zshrc
# ================================
# PROFILE DEV - ZSH
# ================================

export PATH="$HOME/.local/bin:$PATH"

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/jandedobbeleer.omp.json)"

if command -v eza &> /dev/null; then
  alias ll="eza -la --icons"
elif command -v exa &> /dev/null; then
  alias ll="exa -la --icons"
else
  alias ll="ls -la"
fi
alias g="git"
alias py="python3"
alias code="code"

command -v neofetch &> /dev/null && neofetch || true
EOF

chsh -s "$(command -v zsh)" || true

echo "✅ Setup Linux concluído. Reinicie o terminal."
