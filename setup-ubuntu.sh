#!/bin/bash
#
# Ubuntu 24.04 terminal setup — cyberpunk/retro hacker theme.
# Installs apt packages, Nerd Fonts, Kitty, tmux, and shell config.
#
# Usage:
#   cd ~/dotfiles && ./setup-ubuntu.sh
#
# Idempotent — safe to re-run.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# ============================================================
# 1. Platform guard
# ============================================================
if [[ "$(uname)" != "Linux" ]]; then
  err "This script is for Linux only."
  exit 1
fi
if [[ ! -f /etc/debian_version ]]; then
  warn "This script is designed for Ubuntu/Debian. Proceeding anyway..."
fi

# ============================================================
# 2. System update
# ============================================================
info "Updating package lists..."
sudo apt update -qq

# Ensure universe repo is enabled (needed for eza, etc.)
if command -v add-apt-repository &>/dev/null; then
  sudo add-apt-repository -y universe 2>/dev/null || true
fi

# ============================================================
# 3. APT packages
# ============================================================
info "Installing APT packages..."

APT_PACKAGES=(
  zsh
  fzf
  fd-find
  bat
  btop
  ripgrep
  eza
  kitty
  tmux
  cmatrix
  curl
  git
  unzip
  fontconfig
  xclip
  zsh-autosuggestions
  zsh-syntax-highlighting
)

for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null 2>&1; then
    ok "Already installed: $pkg"
  else
    info "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# ============================================================
# 4. Starship (prompt)
# ============================================================
info "Checking starship..."
if command -v starship &>/dev/null; then
  ok "Already installed: starship ($(starship --version 2>/dev/null | head -1))"
else
  info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# ============================================================
# 5. Zoxide (smart cd)
# ============================================================
info "Checking zoxide..."
if command -v zoxide &>/dev/null; then
  ok "Already installed: zoxide"
else
  info "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ============================================================
# 6. Atuin (shell history)
# ============================================================
info "Checking atuin..."
if command -v atuin &>/dev/null; then
  ok "Already installed: atuin"
else
  info "Installing atuin..."
  curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh
fi

# ============================================================
# 7. Fastfetch (system info)
# ============================================================
info "Checking fastfetch..."
if command -v fastfetch &>/dev/null; then
  ok "Already installed: fastfetch"
else
  info "Installing fastfetch via PPA..."
  sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
  sudo apt update -qq
  sudo apt install -y fastfetch
fi

# ============================================================
# 8. Nerd Fonts
# ============================================================
info "Installing Nerd Fonts..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

install_nerd_font() {
  local font_name="$1"
  # Check if any files from this font already exist
  if ls "$FONT_DIR"/${font_name}NerdFont* &>/dev/null 2>&1; then
    ok "Already installed: $font_name Nerd Font"
    return 0
  fi
  info "Downloading $font_name Nerd Font..."
  local tmpzip
  tmpzip=$(mktemp /tmp/${font_name}-XXXXXX.zip)
  if curl -fsSL -o "$tmpzip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"; then
    unzip -qo "$tmpzip" -d "$FONT_DIR" -x "*.md" "*.txt" "LICENSE*" "readme*"
    rm -f "$tmpzip"
    ok "Installed: $font_name Nerd Font"
  else
    err "Failed to download $font_name Nerd Font"
    rm -f "$tmpzip"
  fi
}

install_nerd_font "JetBrainsMono"
install_nerd_font "Hack"
install_nerd_font "Iosevka"

info "Rebuilding font cache..."
fc-cache -f "$FONT_DIR"
ok "Font cache updated"

# ============================================================
# 9. fast-syntax-highlighting (git clone)
# ============================================================
info "Checking fast-syntax-highlighting..."
FSH_DIR="$HOME/.local/share/zsh/plugins/fast-syntax-highlighting"
if [[ -d "$FSH_DIR" ]]; then
  ok "Already installed: fast-syntax-highlighting"
else
  info "Cloning fast-syntax-highlighting..."
  mkdir -p "$(dirname "$FSH_DIR")"
  git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$FSH_DIR"
  ok "Installed: fast-syntax-highlighting"
fi

# ============================================================
# 10. Symlink config files
# ============================================================
info "Symlinking config files..."

symlink_to "config/starship-linux.toml"  "$HOME/.config/starship.toml"
symlink_to "config/bat/config"           "$HOME/.config/bat/config"
symlink_to "config/kitty/kitty.conf"     "$HOME/.config/kitty/kitty.conf"
symlink_to "config/kitty/cyberpunk.conf" "$HOME/.config/kitty/cyberpunk.conf"
symlink_to "config/tmux/tmux.conf"       "$HOME/.config/tmux/tmux.conf"

# ============================================================
# 11. Wire cyberpunk-linux.zsh into .zshrc
# ============================================================
info "Configuring shell..."

ZSHRC="$HOME/.zshrc"
SOURCE_LINE="source \"$DOTFILES_DIR/zsh/cyberpunk-linux.zsh\""

# Ensure .zshrc exists
touch "$ZSHRC"

# Add PATH for ~/.local/bin if not present
if ! grep -qF '.local/bin' "$ZSHRC"; then
  {
    echo ""
    echo '# Local binaries'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> "$ZSHRC"
  ok "Added ~/.local/bin to PATH in .zshrc"
fi

# Add cyberpunk source line if not present
if grep -qF "cyberpunk-linux.zsh" "$ZSHRC"; then
  ok "cyberpunk-linux.zsh already sourced in .zshrc"
else
  {
    echo ""
    echo "# Cyberpunk terminal (managed by dotfiles)"
    echo "$SOURCE_LINE"
  } >> "$ZSHRC"
  ok "Added source line to .zshrc"
fi

# ============================================================
# 12. Default shell
# ============================================================
info "Checking default shell..."
if [[ "$SHELL" == *zsh ]]; then
  ok "Default shell is already zsh"
else
  info "Setting default shell to zsh..."
  chsh -s "$(which zsh)"
  ok "Default shell set to zsh (takes effect on next login)"
fi

# ============================================================
# 13. Done
# ============================================================
echo ""
printf "${CYAN}============================================================${NC}\n"
printf "${GREEN}  Ubuntu setup complete!${NC}\n"
printf "${CYAN}============================================================${NC}\n"
echo ""
echo "What was installed:"
echo "  Terminal:  Kitty (GPU-accelerated, cyberpunk theme)"
echo "  Prompt:    Starship (powerline segments)"
echo "  Shell:     Zsh + autosuggestions + fast-syntax-highlighting"
echo "  History:   Atuin (intelligent Ctrl-R)"
echo "  Finder:    fzf + fd (Ctrl-T files, Alt-C dirs)"
echo "  Tools:     eza (ls), bat (cat), btop (top), fastfetch, zoxide (cd)"
echo "  Mux:       tmux (Catppuccin Mocha status bar)"
echo "  Fonts:     JetBrainsMono, Hack, Iosevka (Nerd Fonts)"
echo ""
echo "Kitty terminal config:"
echo "  Font and colors are pre-configured via symlinked configs."
echo "  Launch with: kitty"
echo ""
echo "tmux is ready:"
echo "  Start:     tmux"
echo "  Splits:    prefix + | (horizontal), prefix + - (vertical)"
echo "  Navigate:  prefix + h/j/k/l"
echo "  Reload:    prefix + r"
echo ""
echo "Restart your terminal or run: source ~/.zshrc"
echo ""
