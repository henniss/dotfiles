syntax on

set nocompatible

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |

set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent
set smarttab
set expandtab

set cursorline
set number
set relativenumber
set scrolloff=8
set signcolumn=yes

set hlsearch " highlight search results
set linebreak

" So that searches are case insensitive unless I include some caps.
set ignorecase
set smartcase

" Let files embed editor settings in their comments.
set modeline
set modelines=5

" Make tabs visible in Makefiles, where they matter.
autocmd FileType make set list listchars=tab:▸\ 

" Reload files changed outside vim when focus returns (needs tmux focus-events).
set autoread
au FocusGained,BufEnter * checktime

" gj/gk are used for movement that respects wrapped lines.
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" most of this config comes from : https://medium.com/@edominguez.se/vim-101-a-comprehensive-guide-to-using-vim-like-an-ide-1-3-vimrc-d484cc41fc2
