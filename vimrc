set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

filetype indent on
syntax enable

set ruler
set nonumber
set nolist
set showcmd
set showmode
set showmatch

set scrolljump=5
set sidescroll=10

set nohlsearch
set incsearch

set autoindent
set noerrorbells
set backspace=indent,eol,start
set tags=tags;/
set undolevels=1000
set viminfo='50,"50
set modelines=0

" Splits navigation
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k

set nu
set relativenumber
colorscheme default

set eol
set autoread

" Python
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix
