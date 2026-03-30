#!/bin/bash
#
# Basic dotfiles setup (platform-agnostic).
# Symlinks vim, inputrc, and git configs.
#
# Usage:
#   cd ~/dotfiles && ./setup.sh
#
# Idempotent — safe to re-run.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

info "Setting up basic dotfiles..."

symlink_to "inputrc"    "$HOME/.inputrc"
symlink_to "vimrc"      "$HOME/.vimrc"
symlink_to "gitconfig"  "$HOME/.gitconfig"

echo ""
ok "Basic setup complete."
