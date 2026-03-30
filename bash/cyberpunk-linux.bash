# Cyberpunk Terminal Setup (Linux/Ubuntu — Bash)
# Sourced automatically by setup-ubuntu.sh. Or manually:
#   source /path/to/dotfiles/bash/cyberpunk-linux.bash
#
# Requires: apt install fzf fd-find bat eza btop tmux kitty cmatrix
# Also: starship, zoxide, atuin, fastfetch (see setup-ubuntu.sh)

# Guard: skip if not interactive
[[ $- != *i* ]] && return

# Ensure ~/.local/bin is in PATH (starship, zoxide, atuin install here)
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# --- Starship Prompt ---
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# --- Atuin (intelligent shell history — Ctrl-R) ---
if command -v atuin &>/dev/null; then
  eval "$(atuin init bash --disable-up-arrow)"
fi

# --- fzf (fuzzy finder — Ctrl-T files, Alt-C dirs) ---
if command -v fzf &>/dev/null; then
  # Ubuntu apt fzf uses file-based shell integration
  [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]] && \
    source /usr/share/doc/fzf/examples/key-bindings.bash
  [[ -f /usr/share/bash-completion/completions/fzf ]] && \
    source /usr/share/bash-completion/completions/fzf

  # Cyberpunk fzf color theme (Catppuccin Mocha)
  export FZF_DEFAULT_OPTS="
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=border:#6c7086
    --border=rounded
    --preview-window=border-rounded
    --prompt='  '
    --pointer='>'
    --marker='*'
  "
  # Use fdfind (Ubuntu name) for file search
  if command -v fdfind &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
  elif command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  fi
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  # Use batcat/bat for preview
  if command -v batcat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'batcat --style=numbers --color=always --line-range :500 {}'"
  elif command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
  fi
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200'"
fi

# --- Zoxide (smart cd — learns frequent dirs) ---
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

# --- Modern CLI Aliases ---
command -v eza &>/dev/null && {
  alias ls='eza --icons --color=always --group-directories-first'
  alias ll='eza --icons --color=always --group-directories-first -la'
  alias lt='eza --icons --color=always --tree --level=2'
}
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
elif command -v batcat &>/dev/null; then
  alias cat='batcat --paging=never'
fi
command -v btop &>/dev/null && alias top='btop'

# --- Fastfetch on new top-level shell ---
if command -v fastfetch &>/dev/null; then
  if [[ $SHLVL -eq 1 ]] && [[ -z "${INSIDE_EMACS:-}" ]] && [[ -z "${VSCODE_INJECTION:-}" ]] && [[ -z "${TMUX:-}" ]]; then
    fastfetch
  fi
fi
