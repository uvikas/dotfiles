# Cyberpunk Terminal Setup
# Sourced automatically by setup-mac.sh. Or manually:
#   source /path/to/dotfiles/zsh/cyberpunk.zsh
#
# Requires: brew install starship fzf fd eza bat btop fastfetch zoxide atuin \
#   zsh-autosuggestions zsh-fast-syntax-highlighting zsh-completions cmatrix

# Guard: skip if not interactive or brew not available
[[ ! -o interactive ]] && return
command -v brew &>/dev/null || return

_brew_prefix="$(brew --prefix)"

# --- Completions ---
fpath=("${_brew_prefix}/share/zsh-completions" $fpath)
autoload -Uz compinit && compinit -C

# --- Starship Prompt ---
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# --- Plugins ---
[[ -f "${_brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "${_brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

[[ -f "${_brew_prefix}/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] && \
  source "${_brew_prefix}/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

# --- Atuin (intelligent shell history) ---
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# --- fzf (fuzzy finder — Ctrl-T files, Alt-C dirs) ---
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)

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
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
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
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v btop &>/dev/null && alias top='btop'

# --- Fastfetch on new top-level shell ---
if command -v fastfetch &>/dev/null; then
  if [[ $SHLVL -eq 1 ]] && [[ -z "$INSIDE_EMACS" ]] && [[ -z "$VSCODE_INJECTION" ]]; then
    fastfetch
  fi
fi

unset _brew_prefix
