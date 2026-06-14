-- Neovim Lua module: treesitter config
-- Loaded from nvim/init.vim when nvim-treesitter is available.
--
-- Compatible with the current (slimmed) nvim-treesitter that focuses on
-- parser installation + Neovim's built-in treesitter support.
-- See the comments in init.vim for installation instructions.
--
-- This gives excellent syntax highlighting and indentation for Python
-- and shell (bash/sh) based on real parse trees instead of fragile regex.

local parsers = {
  "python", "bash",
  -- Supporting languages for a polished daily driver experience
  "lua", "vim", "vimdoc", "markdown",
  "json", "yaml", "toml",
  "dockerfile", "make", "regex", "comment",
}

-- Trigger parser installation for anything not yet installed.
-- This replaces the old ensure_installed behavior.
local ok_install, install = pcall(require, 'nvim-treesitter.install')
if ok_install then
  local ok_cfg, cfg = pcall(require, 'nvim-treesitter.config')
  local installed = {}
  if ok_cfg and cfg.get_installed then
    installed = cfg.get_installed('parsers') or {}
  end

  local to_install = {}
  for _, p in ipairs(parsers) do
    if not vim.tbl_contains(installed, p) then
      table.insert(to_install, p)
    end
  end

  if #to_install > 0 then
    -- This will download/compile the parsers (async, shows summary).
    -- Run :TSInstallInfo or checkhealth if you want to monitor.
    install.install(to_install, { summary = true })
  end
end

-- Enable Tree-sitter highlighting + good indent for the target languages.
-- Call this on FileType so it activates per buffer.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "python", "sh", "bash",
    "lua", "vim",
    "markdown",
    "json", "yaml", "toml",
    "dockerfile", "make",
  },
  callback = function(ev)
    -- Start treesitter highlighting for this buffer (the core "great experience").
    -- Neovim's builtin treesitter will use the parser we installed.
    local lang = ev.match == "sh" and "bash" or ev.match
    pcall(vim.treesitter.start, ev.buf, lang)

    -- Use the treesitter-powered indent from the plugin (better than legacy rules
    -- for Python blocks, shell here-docs, etc.).
    vim.opt_local.indentexpr = "nvim_treesitter#indent()"
  end,
})

-- Optional: Tree-sitter based folding (uses queries from the parsers if available).
-- Start disabled so it doesn't surprise you; enable manually with :set foldenable
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false

-- Note on incremental selection (gnn / grn etc.):
-- That was provided by the old nvim-treesitter "incremental_selection" module.
-- The current minimal nvim-treesitter focuses on parsers + core Neovim integration.
-- You can still do powerful selection with built-in Vim motions, % , or by adding
-- a textobjects plugin later if desired. Let me know if you want a basic version added.
