#!/bin/bash
#
# macOS terminal setup — cyberpunk/retro hacker theme for iTerm2.
# Installs Homebrew packages, Nerd Fonts, color schemes, and shell config.
#
# Usage:
#   cd ~/dotfiles && ./setup-mac.sh
#
# Idempotent — safe to re-run.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

if [[ "$(uname)" != "Darwin" ]]; then
  err "This script is for macOS only."
  exit 1
fi

# ============================================================
# 1. Homebrew
# ============================================================
info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  warn "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed"
else
  ok "Homebrew found: $(brew --prefix)"
fi

# ============================================================
# 2. Brew packages
# ============================================================
info "Installing CLI tools..."

BREW_FORMULAE=(
  starship          # prompt
  fzf               # fuzzy finder
  fd                # fast find
  eza               # modern ls
  bat               # modern cat
  btop              # system monitor
  fastfetch         # system info
  zoxide            # smart cd
  atuin             # shell history
  cmatrix           # matrix rain
  zsh-autosuggestions
  zsh-fast-syntax-highlighting
  zsh-completions
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

# ============================================================
# 3. Symlink config files
# ============================================================
info "Symlinking config files..."

symlink_to "config/starship.toml" "$HOME/.config/starship.toml"
symlink_to "config/bat/config"    "$HOME/.config/bat/config"

# ============================================================
# 4. iTerm2 color schemes
# ============================================================
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

# ============================================================
# 5. Wire cyberpunk.zsh into .zshrc
# ============================================================
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

# ============================================================
# 6. Done
# ============================================================
echo ""
printf "${CYAN}============================================================${NC}\n"
printf "${GREEN}  macOS setup complete!${NC}\n"
printf "${CYAN}============================================================${NC}\n"
echo ""
echo "Manual iTerm2 steps (Cmd+,):"
echo ""
echo "  Font:       Profiles > Text > Font"
echo "              -> JetBrainsMono Nerd Font, 13pt, ligatures ON"
echo ""
echo "  Colors:     Profiles > Colors > Color Presets"
echo "              -> Cyberdyne / Synthwave Everything / Catppuccin Mocha"
echo ""
echo "  Window:     Profiles > Window"
echo "              -> Style: No Title Bar"
echo "              -> Transparency: 15%, Blur: 20"
echo ""
echo "  Theme:      Appearance > General > Theme: Minimal"
echo "  Tabs:       Appearance > Tabs > Tab bar location: Bottom"
echo ""
echo "  Status bar: Profiles > Session > Status bar: Enable"
echo "              -> Add: CPU, Memory, git state, Current Directory"
echo "              -> Style: Auto-Rainbow"
echo ""
echo "  Cursor:     Profiles > Text > Cursor: Vertical Bar, Blinking"
echo ""
echo "Restart your terminal or run: source ~/.zshrc"
echo ""
