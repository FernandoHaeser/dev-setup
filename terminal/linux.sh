#!/usr/bin/env bash

set -e

echo "🚀 Iniciando setup do terminal (Linux)"

WORKDIR="$(mktemp -d -t dev-setup-terminal-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKDIR" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "🔧 Atualizando sistema..."
sudo apt update
sudo apt upgrade -y

echo "📦 Instalando dependências base..."
sudo apt install -y \
  software-properties-common \
  curl \
  wget \
  git \
  terminator \
  zsh \
  fonts-firacode \
  neovim

# ---------- FASTFETCH ----------
echo "🖼️ Instalando Fastfetch..."
if apt-cache show fastfetch >/dev/null 2>&1; then
  sudo apt install -y fastfetch
else
  echo "➡️ Fastfetch não disponível no apt, instalando via GitHub..."
  FASTFETCH_URL=$(curl -fsSL https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
    | grep browser_download_url \
    | grep linux-amd64.deb \
    | cut -d '"' -f 4 \
    | head -n 1)

  if [[ -z "$FASTFETCH_URL" ]]; then
    echo "⚠️  Não foi possível descobrir a URL do Fastfetch (GitHub)."
  else
    wget -O "$WORKDIR/fastfetch.deb" "$FASTFETCH_URL"
    sudo apt install -y "$WORKDIR/fastfetch.deb"
  fi
fi

# ---------- OH MY ZSH ----------
echo "🎨 Instalando Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  export RUNZSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

# ---------- PLUGINS ----------
echo "⚡ Instalando plugins Zsh..."
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
  git clone https://github.com/zsh-users/zsh-completions \
    "$ZSH_CUSTOM/plugins/zsh-completions" || true
fi

# ---------- TEMA ----------
echo "🎭 Instalando Powerlevel10k..."
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k" || true
fi

# ---------- ZSHRC ----------
echo "📝 Criando .zshrc..."
cat > "$HOME/.zshrc" << 'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh

# Fastfetch no início
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# Aliases dev
alias ll="ls -lah"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias v="nvim"

export EDITOR=nvim
EOF

# ---------- TERMINATOR ----------
echo "🖥️ Configurando Terminator..."
mkdir -p "$HOME/.config/terminator"

cat > "$HOME/.config/terminator/config" << 'EOF'
[global_config]
[keybindings]
[profiles]
  [[default]]
    font = Fira Code 11
    use_system_font = False
    background_color = "#1e1e2e"
    foreground_color = "#cdd6f4"
    cursor_color = "#f5e0dc"
    palette = "#45475a:#f38ba8:#a6e3a1:#f9e2af:#89b4fa:#f5c2e7:#94e2d5:#bac2de:#585b70:#f38ba8:#a6e3a1:#f9e2af:#89b4fa:#f5c2e7:#94e2d5:#a6adc8"
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
EOF

# ---------- SHELL PADRÃO ----------
echo "🔁 Definindo Zsh como shell padrão..."
if chsh -s "$(command -v zsh)" >/dev/null 2>&1; then
  echo "✅ Zsh definido como shell padrão"
else
  echo "ℹ️  Não foi possível definir automaticamente (pode exigir senha). Rode manualmente: chsh -s \"$(command -v zsh)\""
fi

echo ""
echo "✅ Ambiente configurado com sucesso!"
echo "👉 Feche o terminal, abra de novo e configure o Powerlevel10k."
