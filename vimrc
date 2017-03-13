"For Raspbian
if has("syntax")
      syntax on
endif

"Light background for gvim
"Dark background for terminal vim
if has('gui_running')
        set background=light
    else
        set background=dark
endif

colorscheme solarized

" Highlight search results
set hlsearch
" Makes search act like search in modern browsers
set incsearch
set smartindent
set ignorecase
set smartcase

"For python programming
set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
filetype indent on

let python_highlight_all = 1
