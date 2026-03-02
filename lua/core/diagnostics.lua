local M = {}

M.display_config = {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
}

M.display_config.signs = { text = {} }
M.display_config.signs.text[vim.diagnostic.severity.ERROR] = "E"
M.display_config.signs.text[vim.diagnostic.severity.WARN] = "W"
M.display_config.signs.text[vim.diagnostic.severity.HINT] = "H"
M.display_config.signs.text[vim.diagnostic.severity.INFO] = "I"

M.workspace_settings = {
  python = { diagnosticMode = "workspace" },
  typescript = { diagnosticMode = "workspace" },
  javascript = { diagnosticMode = "workspace" },
  go = {},
  rust = {},
  lua = {},
}

function M.setup_display()
  -- Configure diagnostic display
  vim.diagnostic.config(M.display_config)
  -- Define signs
  for sev, text in pairs(M.display_config.signs.text) do
    pcall(vim.fn.sign_define, "DiagnosticSign" .. tostring(sev), { text = text, texthl = "DiagnosticSign" .. tostring(sev) })
  end
end

function M.get_workspace_settings(lang)
  return M.workspace_settings[lang] or {}
end

function M.apply_workspace_settings(server_name, settings)
  settings = settings or {}
  if server_name == "pyright" then
    settings.python = settings.python or {}
    settings.python.analysis = settings.python.analysis or {}
    settings.python.analysis.diagnosticMode = "workspace"
    return settings
  end
  if server_name == "ts_ls" then
    settings.typescript = settings.typescript or {}
    settings.javascript = settings.javascript or {}
    settings.typescript.diagnosticMode = "workspace"
    settings.javascript.diagnosticMode = "workspace"
    return settings
  end
  -- For gopls, rust_analyzer, lua_ls return unchanged or defaults
  return settings
end

function M.setup()
  M.setup_display()
end

return M

