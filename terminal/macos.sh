#!/usr/bin/env bash
set -e

echo "🚀 Iniciando setup do terminal (macOS)"

if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install zsh git neofetch exa

brew install jandedobbeleer/oh-my-posh/oh-my-posh

brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font

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

echo "✅ Setup macOS concluído. Reinicie o terminal."
