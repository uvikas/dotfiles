# Cyberpunk Terminal Setup (Linux/Ubuntu)
# Sourced automatically by setup-ubuntu.sh. Or manually:
#   source /path/to/dotfiles/zsh/cyberpunk-linux.zsh
#
# Requires: apt install zsh fzf fd-find bat eza btop tmux kitty cmatrix \
#   zsh-autosuggestions zsh-syntax-highlighting
# Also: starship, zoxide, atuin, fastfetch (see setup-ubuntu.sh)

# Guard: skip if not interactive
[[ ! -o interactive ]] && return

# Ensure ~/.local/bin is in PATH (starship, zoxide, atuin install here)
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Ubuntu binary name aliases (must come before all other tool usage)
command -v batcat &>/dev/null && ! command -v bat &>/dev/null && alias bat='batcat'
command -v fdfind &>/dev/null && ! command -v fd &>/dev/null && alias fd='fdfind'

# --- Completions ---
fpath=(/usr/share/zsh/vendor-completions $fpath)
autoload -Uz compinit && compinit -C

# --- Starship Prompt ---
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# --- Plugins ---
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Prefer fast-syntax-highlighting (git-cloned), fall back to apt version
if [[ -f "$HOME/.local/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$HOME/.local/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# --- Atuin (intelligent shell history) ---
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# --- fzf (fuzzy finder — Ctrl-T files, Alt-C dirs) ---
if command -v fzf &>/dev/null; then
  # Ubuntu apt fzf uses file-based shell integration
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && \
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && \
    source /usr/share/doc/fzf/examples/completion.zsh

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
  eval "$(zoxide init zsh)"
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
  if [[ $SHLVL -eq 1 ]] && [[ -z "$INSIDE_EMACS" ]] && [[ -z "$VSCODE_INJECTION" ]] && [[ -z "$TMUX" ]]; then
    fastfetch
  fi
fi
