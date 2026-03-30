#!/bin/bash
#
# Ubuntu 24.04 terminal setup — cyberpunk/retro hacker theme.
# Installs apt packages, Nerd Fonts, Kitty, tmux, and shell config.
# Uses Bash (not zsh).
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
  bash-completion
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
# 9. Symlink config files
# ============================================================
info "Symlinking config files..."

symlink_to "config/starship-linux.toml"  "$HOME/.config/starship.toml"
symlink_to "config/bat/config"           "$HOME/.config/bat/config"
symlink_to "config/kitty/kitty.conf"     "$HOME/.config/kitty/kitty.conf"
symlink_to "config/kitty/cyberpunk.conf" "$HOME/.config/kitty/cyberpunk.conf"
symlink_to "config/tmux/tmux.conf"       "$HOME/.config/tmux/tmux.conf"

# ============================================================
# 10. Wire cyberpunk-linux.bash into .bashrc
# ============================================================
info "Configuring shell..."

BASHRC="$HOME/.bashrc"
SOURCE_LINE="source \"$DOTFILES_DIR/bash/cyberpunk-linux.bash\""

# Add PATH for ~/.local/bin if not present
if ! grep -qF '.local/bin' "$BASHRC" 2>/dev/null; then
  {
    echo ""
    echo '# Local binaries'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> "$BASHRC"
  ok "Added ~/.local/bin to PATH in .bashrc"
fi

# Add cyberpunk source line if not present
if grep -qF "cyberpunk-linux.bash" "$BASHRC" 2>/dev/null; then
  ok "cyberpunk-linux.bash already sourced in .bashrc"
else
  {
    echo ""
    echo "# Cyberpunk terminal (managed by dotfiles)"
    echo "$SOURCE_LINE"
  } >> "$BASHRC"
  ok "Added source line to .bashrc"
fi

# ============================================================
# 11. Done
# ============================================================
echo ""
printf "${CYAN}============================================================${NC}\n"
printf "${GREEN}  Ubuntu setup complete!${NC}\n"
printf "${CYAN}============================================================${NC}\n"
echo ""
echo "What was installed:"
echo "  Terminal:  Kitty (GPU-accelerated, cyberpunk theme)"
echo "  Prompt:    Starship (powerline segments)"
echo "  Shell:     Bash + starship + atuin + fzf"
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
echo "Restart your terminal or run: source ~/.bashrc"
echo ""
