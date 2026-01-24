#!/usr/bin/env bash

set -e

echo "🚀 Dev Setup - Unix"

if ! command -v node &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install node
  else
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install nodejs -y
  fi
fi

command -v git || sudo apt install git -y

if ! command -v code &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask visual-studio-code
  else
    sudo snap install code --classic
  fi
fi

BASE="$HOME/dev-setup"
git clone https://github.com/fernandohaeser/dev-setup "$BASE" 2>/dev/null || true

cd "$BASE/vscode"
node setup.js

if [[ "$SETUP_TERMINAL" == "true" ]]; then
  cd "$BASE/terminal"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ./macos.sh
  else
    ./linux.sh
  fi
fi

echo "✅ Setup concluído"