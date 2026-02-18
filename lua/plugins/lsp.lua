-- lua/plugins/lsp.lua

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/cmp-nvim-lsp", optional = true },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local keymaps = require("core.keymaps")

      -- ------------------------------------------------------------------
      -- Capabilities (CMP-safe, optional)
      -- ------------------------------------------------------------------
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- ------------------------------------------------------------------
      -- On Attach (for keymaps and formatting)
      -- ------------------------------------------------------------------
      local on_attach = function(client, bufnr)
        -- Disable rename for non-pyright clients to avoid duplicate rename dialogs
        if client.name ~= "pyright" then
          client.server_capabilities.renameProvider = false
          client.server_capabilities.codeActionProvider = false
        end
        keymaps.lsp_on_attach(bufnr)
      end

      -- ------------------------------------------------------------------
      -- Mason
      -- ------------------------------------------------------------------
      mason.setup()

      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls",
          "bashls",
          "jsonls",
          "yamlls",
          "ts_ls",
          "pyright",
          "rust_analyzer",
          "gopls",
        },
      })
      
      -- Manually setup each server
      local servers = { "lua_ls", "bashls", "jsonls", "yamlls", "ts_ls", "pyright", "rust_analyzer", "gopls" }
      for _, server_name in ipairs(servers) do
        local server_config = {
          capabilities = capabilities,
          on_attach = on_attach,
        }
        
        -- Server-specific settings
        if server_name == "lua_ls" then
          server_config.settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          }
        elseif server_name == "ts_ls" then
          server_config.settings = {
            typescript = {
              autoImportFileExcludePatterns = {},
              suggest = { autoImports = true },
              inlayHints = { enabled = true },
            },
          }
        elseif server_name == "pyright" then
          server_config.settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                diagnosticMode = "workspace",
              },
            },
          }
        elseif server_name == "rust_analyzer" then
          server_config.settings = {
            ["rust-analyzer"] = {
              assist = {
                importGranularity = "module",
                importPrefix = "by_self",
              },
              cargo = { loadOutDirsFromCheck = true },
              procMacro = { enable = true },
            },
          }
        elseif server_name == "gopls" then
          server_config.settings = {
            gopls = {
              usePlaceholders = true,
              completeUnimported = true,
            },
          }
        end
        
        lspconfig[server_name].setup(server_config)
      end
    end,
  },
}

