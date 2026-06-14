-- Neovim Lua module: treesitter config
-- Loaded from nvim/init.vim when nvim-treesitter is available.
--
-- Uses the full classic nvim-treesitter.configs API (works great with the
-- pinned v0.9.3 we are using, which is compatible with your Neovim 0.11.6).
-- This enables highlight, indent, incremental selection, etc. for a great
-- Python + shell experience.

-- Make sure the user parser/query install directory is in runtimepath
-- (fixes the "is not in runtimepath" warning in checkhealth).
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site')

require('nvim-treesitter.configs').setup {
  -- Focused on Python + shell (bash) + useful supporting languages.
  ensure_installed = {
    "python", "bash",
    "lua", "vim", "vimdoc", "markdown",
    "json", "yaml", "toml",
    "dockerfile", "make", "regex", "comment",
  },

  -- Sync install so parsers are ready sooner (or remove for async).
  sync_install = false,

  -- Use Tree-sitter for highlighting (far better than legacy syntax).
  highlight = {
    enable = true,
    -- Disable for very large files if needed.
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },

  -- Better indentation than the old indentexpr in many cases.
  indent = { enable = true },

  -- Incremental selection (very useful for Python functions/classes etc.).
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

-- Enable Tree-sitter based folding (uses the queries from installed parsers).
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false   -- start with folds off; use `zi` to toggle

-- The plugin (v0.9.3) + ensure_installed above will handle downloading the
-- parsers for python/bash etc. when you first open Neovim or run :TSInstall.
-- Run `:TSInstall python bash` (with arguments) if you want to force it now.
-- After parsers are installed, restart Neovim or open a .py/.sh file to see
-- the improved highlighting + indent + the gnn/grn selection keys.
