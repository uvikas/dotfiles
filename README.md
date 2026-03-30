# dotfiles

Personal dotfiles with a cyberpunk/retro hacker macOS terminal theme.

## Quick Start

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles

./setup.sh          # basic: vim, inputrc, gitconfig (any platform)
./setup-mac.sh      # macOS: brew tools, fonts, iTerm2, cyberpunk shell
```

Both scripts are idempotent — safe to re-run.

## What's Included

### Basic (`setup.sh`)

Platform-agnostic symlinks for `vimrc`, `inputrc`, `gitconfig`.

### macOS (`setup-mac.sh`)

| Tool | Replaces | What it does |
|------|----------|-------------|
| starship | bash/zsh prompt | Cyberpunk powerline prompt (Rust) |
| fzf + fd | find | Fuzzy file finder (Ctrl-T, Alt-C) |
| eza | ls | Modern ls with icons, tree, git |
| bat | cat | Syntax-highlighted cat (Dracula theme) |
| btop | top/htop | Beautiful system monitor TUI |
| fastfetch | neofetch | System info splash on shell start |
| zoxide | cd | Smart cd that learns frequent dirs |
| atuin | Ctrl-R | Intelligent shell history with TUI |
| cmatrix | - | Matrix rain for aesthetics |

Zsh plugins: **zsh-autosuggestions**, **zsh-fast-syntax-highlighting**

Nerd Fonts: JetBrains Mono, Hack, Iosevka

iTerm2 color schemes: Cyberdyne, Cyberpunk, Cyberpunk Scarlet Protocol, Synthwave, Synthwave Everything, Catppuccin Mocha, Dracula, TokyoNight Storm

## Layout

```
dotfiles/
  lib.sh                      # shared helpers
  setup.sh                    # basic dotfiles (any platform)
  setup-mac.sh                # macOS cyberpunk setup
  zsh/cyberpunk.zsh           # shell config (sourced from .zshrc)
  config/starship.toml        # prompt theme
  config/bat/config           # bat settings
  iterm2/*.itermcolors        # color schemes
  vimrc                       # vim config
  inputrc                     # readline config
  gitconfig                   # git config
```
