-- Diagnostics Configuration (Project-agnostic, respects project settings)
-- This module handles diagnostic display and workspace-wide analysis

local M = {}

-- Diagnostic display configuration (UI concerns)
M.display_config = {
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "●",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}

-- Workspace diagnostic settings per language
-- These respect project config files (tsconfig.json, pyproject.toml, etc.)
M.workspace_settings = {
  python = {
    diagnosticMode = "workspace", -- Respects pyproject.toml, pyrightconfig.json
  },
  typescript = {
    diagnosticMode = "workspace", -- Respects tsconfig.json
  },
  javascript = {
    diagnosticMode = "workspace", -- Respects jsconfig.json
  },
  go = {
    -- gopls always uses workspace mode, respects go.mod
  },
  rust = {
    -- rust-analyzer always uses workspace mode, respects Cargo.toml
  },
  lua = {
    -- lua_ls workspace respects .luarc.json, .stylua.toml
  },
}

-- Setup diagnostic display
function M.setup_display()
  vim.diagnostic.config(M.display_config)
end

-- Get workspace diagnostic settings for a specific language
function M.get_workspace_settings(language)
  return M.workspace_settings[language] or {}
end

-- Apply workspace diagnostics to LSP server settings
function M.apply_workspace_settings(server_name, settings)
  local lang_map = {
    pyright = "python",
    ts_ls = "typescript",
    gopls = "go",
    rust_analyzer = "rust",
    lua_ls = "lua",
  }

  local language = lang_map[server_name]
  if not language then
    return settings
  end

  local workspace_config = M.get_workspace_settings(language)

  -- Merge workspace settings (Deep merge for nested tables)
  if server_name == "pyright" and workspace_config.diagnosticMode then
    settings = settings or {}
    settings.python = settings.python or {}
    settings.python.analysis = settings.python.analysis or {}
    settings.python.analysis.diagnosticMode = workspace_config.diagnosticMode
  elseif server_name == "ts_ls" and workspace_config.diagnosticMode then
    settings = settings or {}
    settings.typescript = settings.typescript or {}
    settings.typescript.diagnosticMode = workspace_config.diagnosticMode
    settings.javascript = settings.javascript or {}
    settings.javascript.diagnosticMode = workspace_config.diagnosticMode
  end

  return settings
end

-- Setup function to be called from core
function M.setup()
  M.setup_display()
end

return M
