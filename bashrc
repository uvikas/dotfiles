set -o vi

export EDITOR=vim
export VISUAL=vim

export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
export HISTSIZE=100000
export HISTFILESIZE=100000
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

export BASH_SILENCE_DEPRECATION_WARNING=1
