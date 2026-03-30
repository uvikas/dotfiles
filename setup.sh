#!/bin/bash
# Symlink vim, inputrc, gitconfig

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

info "Setting up basic dotfiles..."

symlink_to "inputrc"    "$HOME/.inputrc"
symlink_to "vimrc"      "$HOME/.vimrc"
symlink_to "gitconfig"  "$HOME/.gitconfig"

echo ""
ok "Basic setup complete."
