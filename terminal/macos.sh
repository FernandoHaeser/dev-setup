#!/usr/bin/env bash
set -e

echo "🚀 Iniciando setup do terminal (macOS)"

if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install zsh git neofetch eza

brew install jandedobbeleer/oh-my-posh/oh-my-posh

THEME_DIR="$HOME/.config/oh-my-posh"
mkdir -p "$THEME_DIR"
curl -fsSL "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json" \
  -o "$THEME_DIR/jandedobbeleer.omp.json"

brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font

cat << 'EOF' > ~/.zshrc
# ================================
# PROFILE DEV - ZSH
# ================================

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/jandedobbeleer.omp.json)"

alias ll="eza -la --icons"
alias g="git"
alias py="python3"
alias code="code"

command -v neofetch &> /dev/null && neofetch || true
EOF

echo "✅ Setup macOS concluído. Reinicie o terminal."
