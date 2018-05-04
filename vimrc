"For Raspbian
if has("syntax")
        syntax on
endif

"Light background for gvim
"Dark background for terminal vim
if has('gui_running')
        set background=dark
else
        set background=dark
endif
"General appearance
set t_Co=256
let g:solarized_termcolors=256
colorscheme solarized
set number
set showmatch
set textwidth=120
set enc=utf-8

" Highlight search results
set hlsearch
" Makes search act like search in modern browsers
set incsearch
set smartindent
set ignorecase
set smartcase

"For programming
if has("autocmd")
        filetype indent on
        autocmd Filetype python setlocal expandtab smarttab shiftwidth=4 softtabstop=4 tabstop=4 textwidth=80
        autocmd Filetype c,cpp setlocal expandtab shiftwidth=4 tabstop=4 smarttab
else
        set autoindent
endif "has("autocmd")

let python_highlight_all = 1

" highlight 'long' lines (>= 80 symbols) in python files
augroup vimrc_autocmds
        autocmd!
        autocmd FileType python,rst,c,cpp highlight Excess ctermbg=DarkGrey guibg=Black
        autocmd FileType python,rst,c,cpp match Excess /\%81v.*/
        autocmd FileType python,rst,c,cpp set nowrap
        autocmd FileType python,rst,c,cpp set colorcolumn=80
augroup END

set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
