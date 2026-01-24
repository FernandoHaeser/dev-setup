#!/usr/bin/env bash

set -e

echo "🚀 Iniciando setup do terminal (Linux)"

sudo apt update

sudo apt install -y zsh curl git

if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi

sudo apt install -y neofetch

sudo apt install -y exa

mkdir -p ~/.fonts
curl -fLo ~/.fonts/FiraCodeNerdFont.ttf \
https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
fc-cache -fv

cat << 'EOF' > ~/.zshrc
# ================================
# PROFILE DEV - ZSH
# ================================

eval "$(oh-my-posh init zsh --config ~/.cache/oh-my-posh/themes/jandedobbeleer.omp.json)"

alias ll="exa -la --icons"
alias g="git"
alias py="python3"
alias code="code"

neofetch
EOF

chsh -s $(which zsh)

echo "✅ Setup Linux concluído. Reinicie o terminal."
