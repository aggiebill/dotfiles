-- Neovim Lua module: treesitter config
-- Loaded from nvim/init.vim when nvim-treesitter is available.
--
-- This replaces the old inline heredoc (which needed an EOF marker).
-- See the comments in init.vim for installation instructions.

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
