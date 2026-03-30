#!/bin/bash
# Shared helpers

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${CYAN}[*]${NC} %s\n" "$1"; }
ok()    { printf "${GREEN}[+]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
err()   { printf "${RED}[-]${NC} %s\n" "$1"; }

ask() {
  local question="$1"
  read -rp "$question (y/N) " reply
  local yn
  yn=$(echo "$reply" | tr "A-Z" "a-z")
  [[ "$yn" == "y" || "$yn" == "yes" ]]
}

symlink_to() {
  local src="$DOTFILES_DIR/$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    err "Source does not exist: $src"
    return 1
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    local current
    current=$(readlink "$dst")
    if [[ "$current" == "$src" ]]; then
      ok "Link exists: $dst -> $1"
      return 0
    else
      warn "Symlink exists but points elsewhere: $dst -> $current"
      if ask "  Overwrite?"; then
        rm -f "$dst"
      else
        return 0
      fi
    fi
  elif [[ -e "$dst" ]]; then
    warn "File exists: $dst"
    if ask "  Back up to ${dst}.bak and replace?"; then
      mv "$dst" "${dst}.bak"
      ok "Backed up: ${dst}.bak"
    else
      return 0
    fi
  fi

  ln -s "$src" "$dst"
  ok "Linked: $dst -> $1"
}
