#!/bin/bash
# Ubuntu setup: apt tools, fonts, Kitty, tmux, bash config

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

# Platform guard
if [[ "$(uname)" != "Linux" ]]; then
  err "This script is for Linux only."
  exit 1
fi
if [[ ! -f /etc/debian_version ]]; then
  warn "This script is designed for Ubuntu/Debian. Proceeding anyway..."
fi

# System update
info "Updating package lists..."
sudo apt update -qq
if command -v add-apt-repository &>/dev/null; then
  sudo add-apt-repository -y universe 2>/dev/null || true
fi

# APT packages
info "Installing APT packages..."

APT_PACKAGES=(
  fzf
  fd-find
  bat
  btop
  ripgrep
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

# eza (not in default repos)
info "Checking eza..."
if command -v eza &>/dev/null; then
  ok "Already installed: eza"
else
  info "Adding eza apt repository..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update -qq
  sudo apt install -y eza
fi

# Starship
info "Checking starship..."
if command -v starship &>/dev/null; then
  ok "Already installed: starship ($(starship --version 2>/dev/null | head -1))"
else
  info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Zoxide
info "Checking zoxide..."
if command -v zoxide &>/dev/null; then
  ok "Already installed: zoxide"
else
  info "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Atuin
info "Checking atuin..."
if command -v atuin &>/dev/null; then
  ok "Already installed: atuin"
else
  info "Installing atuin..."
  curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh
fi

# Fastfetch
info "Checking fastfetch..."
if command -v fastfetch &>/dev/null; then
  ok "Already installed: fastfetch"
else
  info "Installing fastfetch via PPA..."
  sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
  sudo apt update -qq
  sudo apt install -y fastfetch
fi

# Nerd Fonts
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

# Symlinks
info "Symlinking config files..."

symlink_to "config/blerc"                "$HOME/.blerc"
symlink_to "config/starship-linux.toml"  "$HOME/.config/starship.toml"
symlink_to "config/bat/config"           "$HOME/.config/bat/config"
symlink_to "config/kitty/kitty.conf"     "$HOME/.config/kitty/kitty.conf"
symlink_to "config/kitty/cyberpunk.conf" "$HOME/.config/kitty/cyberpunk.conf"
symlink_to "config/tmux/tmux.conf"       "$HOME/.config/tmux/tmux.conf"

# Wire cyberpunk-linux.bash into .bashrc
info "Configuring shell..."

BASHRC="$HOME/.bashrc"
SOURCE_LINE="source \"$DOTFILES_DIR/bash/cyberpunk-linux.bash\""

if ! grep -qF '.local/bin' "$BASHRC" 2>/dev/null; then
  {
    echo ""
    echo '# Local binaries'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> "$BASHRC"
  ok "Added ~/.local/bin to PATH in .bashrc"
fi

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

# Done
echo ""
printf "${CYAN}============================================================${NC}\n"
printf "${GREEN}  Ubuntu setup complete!${NC}\n"
printf "${CYAN}============================================================${NC}\n"
echo ""
echo "Restart your terminal or run: source ~/.bashrc"
echo ""
