#!/usr/bin/env bash
set -euo pipefail

supports_color() {
  [[ -t 1 ]] || return 1
  command -v tput >/dev/null 2>&1 || return 1
  [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]
}

if supports_color; then
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
  RESET="$(tput sgr0)"
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  CYAN="$(tput setaf 6)"
else
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""
fi

hr() { echo "${DIM}----------------------------------------------${RESET}"; }
header() {
  echo "${BOLD}${BLUE}Terminal Setup${RESET}${DIM} · macOS + iTerm2${RESET}"
  hr
}
step() { echo "${CYAN}▶${RESET} $*"; }
ok() { echo "${GREEN}✅${RESET} $*"; }
warn() { echo "${YELLOW}⚠️${RESET}  $*"; }
info() { echo "${DIM}ℹ️${RESET}  $*"; }

header

# ------------------------------------------------
# 1. Xcode Command Line Tools
# ------------------------------------------------
if ! xcode-select -p &>/dev/null; then
  step "Installing Xcode Command Line Tools..."
  xcode-select --install
  warn "Finish installation and run the script again."
  exit 1
else
  ok "Xcode Command Line Tools already installed"
fi

# ------------------------------------------------
# 2. Homebrew
# ------------------------------------------------
if ! command -v brew &>/dev/null; then
  step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is available in this non-login script session
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew &>/dev/null; then
  echo "${RED}❌${RESET} Homebrew not found on PATH after install."
  info "Reopen your terminal and run again."
  exit 1
fi

BREW_PREFIX="$(brew --prefix)"

# Persist brew to future shells
if [[ "$BREW_PREFIX" == "/opt/homebrew" ]]; then
  grep -q 'eval "\$\(/opt/homebrew/bin/brew shellenv\)"' "$HOME/.zprofile" 2>/dev/null || \
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
elif [[ "$BREW_PREFIX" == "/usr/local" ]]; then
  grep -q 'eval "\$\(/usr/local/bin/brew shellenv\)"' "$HOME/.zprofile" 2>/dev/null || \
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

brew update

# ------------------------------------------------
# 3. CLI Tools
# ------------------------------------------------
step "Installing CLI tools..."
brew install \
  git wget curl fzf bat eza htop tmux ripgrep tree jq neovim gnupg fastfetch

# ------------------------------------------------
# 4. Dev Tools
# ------------------------------------------------
step "Installing dev tools..."
brew install \
  node python openjdk go \
  kubectl helm

# Docker: Docker Desktop is the most common choice on macOS
brew install --cask docker

# ------------------------------------------------
# 5. iTerm2
# ------------------------------------------------
if ! [ -d "/Applications/iTerm.app" ]; then
  step "Installing iTerm2..."
  brew install --cask iterm2
else
  ok "iTerm2 already installed"
fi

# ------------------------------------------------
# 6. Nerd Font
# ------------------------------------------------
step "Installing Meslo Nerd Font..."
brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
brew install --cask font-meslo-lg-nerd-font || true

# ------------------------------------------------
# 7. Oh My Zsh
# ------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  step "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  ok "Oh My Zsh already installed"
fi

# ------------------------------------------------
# 8. Powerlevel10k (Oh My Zsh theme)
# ------------------------------------------------
step "Installing Powerlevel10k..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/themes"
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# ------------------------------------------------
# 9. Zsh Plugins
# ------------------------------------------------
step "Installing Zsh plugins..."
brew install \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  zsh-completions

# ------------------------------------------------
# 10. .zshrc (SAFE + CLEAN)
# ------------------------------------------------
step "Configuring .zshrc..."

ZSHRC="$HOME/.zshrc"
cp "$ZSHRC" "$ZSHRC.backup.$(date +%s)" 2>/dev/null || true

cat << 'EOF' > "$ZSHRC"
# =================================================
# Powerlevel10k Instant Prompt (MUST BE FIRST)
# =================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =================================================
# Homebrew PATH (safe for non-login shells)
# =================================================
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# =================================================
# Fastfetch (SAFE) — keep near the top
# =================================================
if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# =================================================
# Oh My Zsh
# =================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git docker kubectl npm node
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Make brew zsh-completions available before compinit (Oh My Zsh runs compinit)
if command -v brew >/dev/null 2>&1; then
  fpath+=("$(brew --prefix)/share/zsh-completions")
fi

source "$ZSH/oh-my-zsh.sh"

# =================================================
# Zsh Plugins (Homebrew)
# =================================================
if command -v brew >/dev/null 2>&1; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# =================================================
# FZF
# =================================================
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# =================================================
# Aliases
# =================================================
alias ls="eza --icons"
alias ll="eza -lah --icons"
alias cat="bat"
alias grep="rg"
alias top="htop"
alias vim="nvim"

# =================================================
# Java
# =================================================
export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || true)

# =================================================
# History
# =================================================
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS
EOF

# ------------------------------------------------
# 11. Default shell
# ------------------------------------------------
if [[ "${SHELL:-}" != *"zsh"* ]]; then
  step "Setting Zsh as default shell..."
  chsh -s "$(command -v zsh)" || true
fi

# ------------------------------------------------
# 12. Tokyo Night iTerm2 Theme
# ------------------------------------------------
COLOR_FILE="$HOME/TokyoNight.itermcolors"

step "Creating Tokyo Night color preset..."
cat > "$COLOR_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Background Color</key>
  <dict>
    <key>Red Component</key><real>0.102</real>
    <key>Green Component</key><real>0.106</real>
    <key>Blue Component</key><real>0.149</real>
  </dict>
  <key>Foreground Color</key>
  <dict>
    <key>Red Component</key><real>0.753</real>
    <key>Green Component</key><real>0.792</real>
    <key>Blue Component</key><real>0.961</real>
  </dict>
</dict>
</plist>
EOF

# ------------------------------------------------
# Final
# ------------------------------------------------
hr
ok "Setup completed successfully"
info "Next steps:"
info "1) Open a NEW terminal (iTerm2)"
info "2) Powerlevel10k wizard will start (or run: p10k configure)"
info "3) iTerm2 → Settings → Profiles → Colors → Import: TokyoNight.itermcolors"
info "4) Profiles → Text → MesloLGS Nerd Font (13)"
hr

open -a iTerm || true
