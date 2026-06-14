" Neovim configuration for aggiebill/dotfiles
"
" Neovim is the PRIMARY editor (replaces vim for daily use).
" This file bootstraps the shared configuration from .vimrc + ~/.vim/
" (colors, autocmds, indentation rules, solarized + base16 themes, etc.)
" and then adds modern/WSL-friendly improvements on top.
"
" The vim/ directory and vimrc are deliberately kept as the shared backend
" so that classic `vim` (and any scripts/tools that call it) continue to work.
"
" Color schemes now come from git submodules (see vim/bundle/).
" This file is symlinked to ~/.config/nvim/init.vim during setup.
" See also: bash_aliases (EDITOR=nvim + `alias vim='nvim'`) and gitconfig.

" ------------------------------------------------------------
" Make Neovim find the shared ~/.vim directory (colors, syntax, etc.)
" ------------------------------------------------------------
set runtimepath^=~/.vim
set runtimepath+=~/.vim/after

" Use the same package path as vim (shared backend)
let &packpath = &runtimepath

" Make sure submodule colorschemes are discoverable (base16 + solarized).
" These lines are also in vimrc, but having them here is defensive.
set runtimepath^=~/.vim/bundle/base16-vim
set runtimepath^=~/.vim/bundle/vim-colors-solarized

" Source the main shared configuration from the vim/ backend
" (colors, autocmds, Python/C/LaTeX rules, etc.)
source ~/.vimrc

" ============================================================
" Neovim-specific and WSL enhancements (added on top)
" ============================================================

" Truecolor support — essential for modern terminals (Windows Terminal,
" VS Code integrated terminal, WezTerm, Alacritty, etc.)
set termguicolors

" Use the system clipboard for yank/paste
" In WSL this works via xclip (already installed) or Neovim's built-in OSC 52
" fallback on recent versions. No win32yank required for basic use.
set clipboard+=unnamedplus

" Quality-of-life improvements that are safe and pleasant in Neovim 0.10+
set mouse=a                 " Enable mouse in all modes
set numberwidth=4
set signcolumn=yes          " Always show sign column (prevents text shift)
set splitbelow
set splitright

" Slightly more modern search behavior (these are already in vimrc but reinforced)
set ignorecase
set smartcase
set incsearch
set hlsearch

" Make it obvious we're in a Neovim buffer when it matters
" (title already set by vimrc in most cases)
if has('nvim')
    set title
endif

" ------------------------------------------------------------
" Future extension points (commented examples)
" ------------------------------------------------------------
" If you later want to add Lua config, you can do:
"   lua require('init')
"
" For Treesitter, LSP, etc. you would typically install a plugin manager
" (lazy.nvim, packer, etc.) and put Lua files under ~/.config/nvim/lua/
"
" Example clipboard provider override if you install win32yank:
"   let g:clipboard = {
"       \ 'name': 'win32yank',
"       \ 'copy': { '+': 'win32yank.exe -i --crlf', '*': 'win32yank.exe -i --crlf' },
"       \ 'paste': { '+': 'win32yank.exe -o --lf', '*': 'win32yank.exe -o --lf' },
"       \ 'cache_enabled': 0,
"       \ }

" Nothing else is required for day-to-day use — the heavy lifting
" (colorscheme, indentation rules, Python/C/LaTeX specifics, excess line highlighting, etc.)
" comes from the shared ~/.vimrc + ~/.vim/ backend.

" ============================================
" Tree-sitter (recommended modern replacement for legacy syntax files)
" ============================================
"
" After installing nvim-treesitter (see README.md), this enables superior
" highlighting, indentation, and folds for Python and other languages.
" This completely replaces the old vim/syntax/python.vim (removed in 2026).
"
" Installation (minimal, no plugin manager required):
"   mkdir -p ~/.vim/pack/plugins/start
"   git clone https://github.com/nvim-treesitter/nvim-treesitter \
"       ~/.vim/pack/plugins/start/nvim-treesitter
"
" Then run inside Neovim:
"   :TSInstall python bash
"
" IMPORTANT: In the current version of nvim-treesitter, bare `:TSInstall`
" gives "E471: Argument required". You must pass the language name(s).
" Use <Tab> after `:TSInstall ` for completion of available parsers.
"
" The Lua configuration in nvim/lua/treesitter.lua will also automatically
" trigger installation of the key parsers (python, bash + supporting)
" the first time you start Neovim. It then enables treesitter highlighting
" and indent automatically for those filetypes.
"
" The Lua configuration lives in nvim/lua/treesitter.lua (no heredoc/EOF
" needed in init.vim). It is loaded only if the plugin is present.
if has('nvim-0.9')
  " Safe require: the treesitter plugin itself is optional.
  lua pcall(require, 'treesitter')
endif
