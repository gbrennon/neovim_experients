-- LSP Configuration using vim.lsp.config (Neovim 0.11+)

local M = {}

M.servers = {
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },

  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  },

  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },

  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = { command = "clippy" },
      },
    },
  },

  metals = {
    cmd = { "metals" },
    filetypes = { "scala", "sbt", "java" },
    root_markers = { "build.sbt", ".scala-build", "build.sc", "build.gradle", "pom.xml", ".git" },
    init_options = { statusBarProvider = "off" },
    settings = {
      metals = {
        showImplicitArguments = true,
        excludedPackages = {},
      },
    },
  },

  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    settings = {
      typescript = {
        preferences = {
          importModuleSpecifierPreference = "relative",
        },
      },
      javascript = {
        preferences = {
          importModuleSpecifierPreference = "relative",
        },
      },
    },
  },

  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git" },
  },

  yamlls = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    root_markers = { ".git" },
  },

  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html", "templ" },
    root_markers = { "package.json", ".git" },
  },

  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_markers = { "package.json", ".git" },
  },
}

function M.server_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if cmp_ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
  return capabilities
end

function M.setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = "always" },
  })

  local signs = { Error = " ", Warn = " ", Hint = "ó°   ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end
end

function M.setup_servers(on_attach)
  local capabilities = M.get_capabilities()

  for name, config in pairs(M.servers) do
    local cmd_name = config.cmd[1]
    if M.server_exists(cmd_name) then
      config.capabilities = capabilities
      config.on_attach = on_attach
      vim.lsp.config[name] = config
      vim.lsp.enable(name)
    end
  end
end

function M.config()
  local keymaps = require("core.keymaps")

  M.setup_diagnostics()

  local on_attach = function(client, bufnr)
    keymaps.lsp_on_attach(bufnr)
  end

  M.setup_servers(on_attach)
end

-- Plugin spec for lazy.nvim
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = M.config,
  _module = M,
}
