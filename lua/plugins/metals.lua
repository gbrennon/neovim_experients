-- Plugin: nvim-metals integration
local M = {}

function M.config()
  local ok, metals = pcall(require, "metals")
  if not ok then return end

  local config = metals.bare_config()

  config.settings = {
    showImplicitArguments = true,
  }

  config.init_options = config.init_options or {}
  config.init_options.statusBarProvider = "on"

  -- Wire up capabilities and keymaps (same as other LSP servers)
  local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    config.capabilities = cmp.default_capabilities()
  end

  config.on_attach = function(client, bufnr)
    require("core.keymaps").lsp_on_attach(bufnr)
  end

  -- Must be inside a FileType autocmd — metals.initialize_or_attach
  -- needs to run after the buffer filetype is set, not at plugin load time
  local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt", "java" },
    callback = function()
      metals.initialize_or_attach(config)
    end,
    group = group,
  })
end

return {
  "scalameta/nvim-metals",
  dependencies = { "nvim-lua/plenary.nvim" },  -- required by nvim-metals
  ft = { "scala", "sbt", "java" },
  config = M.config,
  _module = M,
}
