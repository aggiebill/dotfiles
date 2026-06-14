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
"   :TSInstall python lua vim bash
"
if has('nvim-0.9')
lua << EOF
    local ok, configs = pcall(require, 'nvim-treesitter.configs')
    if ok then
      configs.setup {
        -- Parsers to install automatically on first use (or run :TSInstall manually)
        ensure_installed = { "python", "lua", "vim", "vimdoc", "bash", "markdown" },

        -- Use Tree-sitter for highlighting (far better than legacy syntax/)
        highlight = {
          enable = true,
          -- Disable for very large files if needed
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },

        -- Better indentation than the old indentexpr in many cases
        indent = { enable = true },

        -- Incremental selection (very useful)
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      }

      -- Optional: enable folding based on Tree-sitter
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false   -- start with folds open
    end
EOF
endif
