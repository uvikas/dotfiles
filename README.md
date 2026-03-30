# dotfiles

Personal dotfiles with cyberpunk/retro hacker terminal themes for macOS and Ubuntu.

## Quick Start

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles

./setup.sh              # basic: vim, inputrc, gitconfig (any platform)
./setup-mac.sh          # macOS: brew tools, fonts, iTerm2, zsh cyberpunk shell
./setup-ubuntu.sh       # Ubuntu 24.04: apt tools, fonts, Kitty, tmux, bash cyberpunk shell
```

All scripts are idempotent — safe to re-run.

## What's Included

### Basic (`setup.sh`)

Platform-agnostic symlinks for `vimrc`, `inputrc`, `gitconfig`.

### macOS (`setup-mac.sh`)

Shell: **Zsh** with zsh-autosuggestions + zsh-fast-syntax-highlighting

| Tool | Replaces | What it does |
|------|----------|-------------|
| starship | zsh prompt | Cyberpunk powerline prompt (Rust) |
| fzf + fd | find | Fuzzy file finder (Ctrl-T, Alt-C) |
| eza | ls | Modern ls with icons, tree, git |
| bat | cat | Syntax-highlighted cat (Dracula theme) |
| btop | top/htop | Beautiful system monitor TUI |
| fastfetch | neofetch | System info splash on shell start |
| zoxide | cd | Smart cd that learns frequent dirs |
| atuin | Ctrl-R | Intelligent shell history with TUI |
| cmatrix | - | Matrix rain for aesthetics |

Nerd Fonts: JetBrains Mono, Hack, Iosevka

iTerm2 color schemes: Cyberdyne, Cyberpunk, Cyberpunk Scarlet Protocol, Synthwave, Synthwave Everything, Catppuccin Mocha, Dracula, TokyoNight Storm

### Ubuntu 24.04 (`setup-ubuntu.sh`)

Shell: **Bash** with starship + atuin + fzf

Same CLI tool stack as macOS (starship, fzf, fd, eza, bat, btop, fastfetch, zoxide, atuin, cmatrix), plus:

| Extra | What it does |
|-------|-------------|
| Kitty | GPU-accelerated terminal with cyberpunk Catppuccin Mocha theme |
| tmux | Terminal multiplexer with Catppuccin Mocha status bar |

Handles Ubuntu quirks automatically (`bat`->`batcat`, `fd`->`fdfind`).

## Layout

```
dotfiles/
  lib.sh                          # shared helpers
  setup.sh                        # basic dotfiles (any platform)
  setup-mac.sh                    # macOS cyberpunk setup
  setup-ubuntu.sh                 # Ubuntu 24.04 cyberpunk setup
  zsh/
    cyberpunk.zsh                 # macOS zsh config
  bash/
    cyberpunk-linux.bash          # Ubuntu bash config
  config/
    starship.toml                 # macOS prompt theme
    starship-linux.toml           # Linux prompt theme (with hostname for SSH)
    bat/config                    # bat settings (shared)
    kitty/kitty.conf              # Kitty terminal config
    kitty/cyberpunk.conf          # Kitty color scheme
    tmux/tmux.conf                # tmux config + Catppuccin status bar
  iterm2/*.itermcolors            # macOS iTerm2 color schemes
  vimrc                           # vim config
  inputrc                         # readline config
  gitconfig                       # git config
```
