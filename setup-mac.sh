#!/bin/bash
# macOS setup: brew tools, fonts, iTerm2 themes, zsh config

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

if [[ "$(uname)" != "Darwin" ]]; then
  err "This script is for macOS only."
  exit 1
fi

# Homebrew
info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  warn "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed"
else
  ok "Homebrew found: $(brew --prefix)"
fi

# Brew packages
info "Installing CLI tools..."

BREW_FORMULAE=(
  starship fzf fd eza bat btop fastfetch zoxide atuin cmatrix
  zsh-autosuggestions zsh-fast-syntax-highlighting zsh-completions
)

BREW_CASKS=(
  font-jetbrains-mono-nerd-font
  font-hack-nerd-font
  font-iosevka-nerd-font
)

for pkg in "${BREW_FORMULAE[@]}"; do
  if brew list --formula "$pkg" &>/dev/null; then
    ok "Already installed: $pkg"
  else
    info "Installing $pkg..."
    brew install "$pkg"
  fi
done

for cask in "${BREW_CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    ok "Already installed: $cask"
  else
    info "Installing $cask..."
    brew install --cask "$cask"
  fi
done

# Symlinks
info "Symlinking config files..."

symlink_to "config/starship.toml" "$HOME/.config/starship.toml"
symlink_to "config/bat/config"    "$HOME/.config/bat/config"

# iTerm2 color schemes
info "Importing iTerm2 color schemes..."
if [[ -d "$DOTFILES_DIR/iterm2" ]]; then
  for scheme in "$DOTFILES_DIR"/iterm2/*.itermcolors; do
    if [[ -f "$scheme" ]]; then
      open "$scheme"
      ok "Imported: $(basename "$scheme")"
    fi
  done
  echo ""
  warn "Color schemes imported into iTerm2."
  warn "Select one in: iTerm2 > Settings > Profiles > Colors > Color Presets"
fi

# Wire cyberpunk.zsh into .zshrc
info "Configuring shell..."

ZSHRC="$HOME/.zshrc"
SOURCE_LINE="source \"$DOTFILES_DIR/zsh/cyberpunk.zsh\""

if [[ -f "$ZSHRC" ]] && grep -qF "cyberpunk.zsh" "$ZSHRC"; then
  ok "cyberpunk.zsh already sourced in .zshrc"
else
  {
    echo ""
    echo "# Cyberpunk terminal (managed by dotfiles)"
    echo "$SOURCE_LINE"
  } >> "$ZSHRC"
  ok "Added source line to .zshrc"
fi

# Done
echo ""
printf "${CYAN}============================================================${NC}\n"
printf "${GREEN}  macOS setup complete!${NC}\n"
printf "${CYAN}============================================================${NC}\n"
echo ""
echo "Restart your terminal or run: source ~/.zshrc"
echo ""
