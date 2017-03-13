colorscheme desert
" Highlight search results
set hlsearch
" Makes search act like search in modern browsers
set incsearch
set smartindent
set ignorecase
set smartcase

"set background=dark

set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
filetype indent on

let python_highlight_all = 1

"For Raspbian
if has("syntax")
      syntax on
endif
