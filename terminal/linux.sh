#!/usr/bin/env bash

set -e

echo "🚀 Iniciando setup do terminal (Linux)"

sudo apt update

sudo apt install -y \
  zsh \
  curl \
  git \
  neofetch

if ! command -v eza &> /dev/null; then
  sudo apt install -y eza
fi

if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

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

eval "$(oh-my-posh init zsh --config ~/.cache/oh-my-posh/themes/jandedobbeleer.omp.json)"

alias ll="eza -la --icons"
alias g="git"
alias py="python3"
alias code="code"

neofetch
EOF

chsh -s "$(which zsh)"

echo "✅ Setup Linux concluído. Reinicie o terminal."
