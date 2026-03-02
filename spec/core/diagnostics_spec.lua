-- Tests for core/diagnostics.lua
local helper = require("spec.spec_helper")

describe("core.diagnostics", function()
  before_each(function()
    helper.before_each()
  end)

  describe("module structure", function()
    it("should load without errors", function()
      assert.has_no.errors(function()
        require("core.diagnostics")
      end)
    end)

    it("should return a module table", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics)
    end)

    it("should have setup function", function()
      local diagnostics = require("core.diagnostics")
      assert.is_function(diagnostics.setup)
    end)

    it("should have setup_display function", function()
      local diagnostics = require("core.diagnostics")
      assert.is_function(diagnostics.setup_display)
    end)

    it("should have get_workspace_settings function", function()
      local diagnostics = require("core.diagnostics")
      assert.is_function(diagnostics.get_workspace_settings)
    end)

    it("should have apply_workspace_settings function", function()
      local diagnostics = require("core.diagnostics")
      assert.is_function(diagnostics.apply_workspace_settings)
    end)
  end)

  describe("display_config", function()
    it("should be a table", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.display_config)
    end)

    it("should enable virtual_text", function()
      local diagnostics = require("core.diagnostics")
      assert.is_true(diagnostics.display_config.virtual_text)
    end)

    it("should enable signs", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.display_config.signs)
    end)

    it("should enable underline", function()
      local diagnostics = require("core.diagnostics")
      assert.is_true(diagnostics.display_config.underline)
    end)

    it("should disable update_in_insert", function()
      local diagnostics = require("core.diagnostics")
      assert.is_false(diagnostics.display_config.update_in_insert)
    end)

    it("should enable severity_sort", function()
      local diagnostics = require("core.diagnostics")
      assert.is_true(diagnostics.display_config.severity_sort)
    end)

    it("should have float configuration", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.display_config.float)
    end)

    it("should use rounded border for float", function()
      local diagnostics = require("core.diagnostics")
      assert.equals("rounded", diagnostics.display_config.float.border)
    end)

    it("should show source in float", function()
      local diagnostics = require("core.diagnostics")
      assert.equals("always", diagnostics.display_config.float.source)
    end)
  end)

  describe("signs configuration", function()
    it("should be configured in display_config", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.display_config.signs)
    end)

    it("should have text configuration", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.display_config.signs.text)
    end)

    it("should have Error sign text", function()
      local diagnostics = require("core.diagnostics")
      assert.is_string(diagnostics.display_config.signs.text[vim.diagnostic.severity.ERROR])
    end)

    it("should have Warn sign text", function()
      local diagnostics = require("core.diagnostics")
      assert.is_string(diagnostics.display_config.signs.text[vim.diagnostic.severity.WARN])
    end)

    it("should have Hint sign text", function()
      local diagnostics = require("core.diagnostics")
      assert.is_string(diagnostics.display_config.signs.text[vim.diagnostic.severity.HINT])
    end)

    it("should have Info sign text", function()
      local diagnostics = require("core.diagnostics")
      assert.is_string(diagnostics.display_config.signs.text[vim.diagnostic.severity.INFO])
    end)
  end)

  describe("workspace_settings", function()
    it("should be a table", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.workspace_settings)
    end)

    it("should have python settings", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.workspace_settings.python)
    end)

    it("should set python diagnosticMode to workspace", function()
      local diagnostics = require("core.diagnostics")
      assert.equals("workspace", diagnostics.workspace_settings.python.diagnosticMode)
    end)

    it("should have typescript settings", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.workspace_settings.typescript)
    end)

    it("should set typescript diagnosticMode to workspace", function()
      local diagnostics = require("core.diagnostics")
      assert.equals("workspace", diagnostics.workspace_settings.typescript.diagnosticMode)
    end)

    it("should have javascript settings", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.workspace_settings.javascript)
    end)

    it("should set javascript diagnosticMode to workspace", function()
      local diagnostics = require("core.diagnostics")
      assert.equals("workspace", diagnostics.workspace_settings.javascript.diagnosticMode)
    end)

    it("should have go settings placeholder", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.workspace_settings.go)
    end)

    it("should have rust settings placeholder", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.workspace_settings.rust)
    end)

    it("should have lua settings placeholder", function()
      local diagnostics = require("core.diagnostics")
      assert.is_table(diagnostics.workspace_settings.lua)
    end)
  end)

  describe("setup_display", function()
    it("should run without error", function()
      local diagnostics = require("core.diagnostics")
      assert.has_no.errors(function()
        diagnostics.setup_display()
      end)
    end)

    it("should configure vim.diagnostic", function()
      local diagnostics = require("core.diagnostics")
      diagnostics.setup_display()
      local state = helper.vim_mock.get_state()
      assert.is_not_nil(state.diagnostic_config)
    end)

    it("should set virtual_text config", function()
      local diagnostics = require("core.diagnostics")
      diagnostics.setup_display()
      local state = helper.vim_mock.get_state()
      assert.is_true(state.diagnostic_config.virtual_text)
    end)

    it("should set signs config with text", function()
      local diagnostics = require("core.diagnostics")
      diagnostics.setup_display()
      local state = helper.vim_mock.get_state()
      assert.is_table(state.diagnostic_config.signs)
      assert.is_table(state.diagnostic_config.signs.text)
    end)

    it("can be called multiple times without error", function()
      local diagnostics = require("core.diagnostics")
      assert.has_no.errors(function()
        diagnostics.setup_display()
        diagnostics.setup_display()
      end)
    end)
  end)

  describe("get_workspace_settings", function()
    it("should return settings for python", function()
      local diagnostics = require("core.diagnostics")
      local settings = diagnostics.get_workspace_settings("python")
      assert.is_table(settings)
      assert.equals("workspace", settings.diagnosticMode)
    end)

    it("should return settings for typescript", function()
      local diagnostics = require("core.diagnostics")
      local settings = diagnostics.get_workspace_settings("typescript")
      assert.is_table(settings)
      assert.equals("workspace", settings.diagnosticMode)
    end)

    it("should return settings for javascript", function()
      local diagnostics = require("core.diagnostics")
      local settings = diagnostics.get_workspace_settings("javascript")
      assert.is_table(settings)
      assert.equals("workspace", settings.diagnosticMode)
    end)

    it("should return settings for go", function()
      local diagnostics = require("core.diagnostics")
      local settings = diagnostics.get_workspace_settings("go")
      assert.is_table(settings)
    end)

    it("should return settings for rust", function()
      local diagnostics = require("core.diagnostics")
      local settings = diagnostics.get_workspace_settings("rust")
      assert.is_table(settings)
    end)

    it("should return settings for lua", function()
      local diagnostics = require("core.diagnostics")
      local settings = diagnostics.get_workspace_settings("lua")
      assert.is_table(settings)
    end)

    it("should return empty table for unknown language", function()
      local diagnostics = require("core.diagnostics")
      local settings = diagnostics.get_workspace_settings("unknown")
      assert.is_table(settings)
      assert.equals(0, #vim.tbl_keys(settings))
    end)
  end)

  describe("apply_workspace_settings", function()
    it("should apply settings for pyright", function()
      local diagnostics = require("core.diagnostics")
      local settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
          },
        },
      }
      local result = diagnostics.apply_workspace_settings("pyright", settings)
      assert.is_table(result)
      assert.equals("workspace", result.python.analysis.diagnosticMode)
    end)

    it("should preserve existing pyright settings", function()
      local diagnostics = require("core.diagnostics")
      local settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      }
      local result = diagnostics.apply_workspace_settings("pyright", settings)
      assert.is_true(result.python.analysis.autoSearchPaths)
      assert.is_true(result.python.analysis.useLibraryCodeForTypes)
      assert.equals("workspace", result.python.analysis.diagnosticMode)
    end)

    it("should apply settings for ts_ls", function()
      local diagnostics = require("core.diagnostics")
      local settings = {
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
      }
      local result = diagnostics.apply_workspace_settings("ts_ls", settings)
      assert.equals("workspace", result.typescript.diagnosticMode)
      assert.equals("workspace", result.javascript.diagnosticMode)
    end)

    it("should preserve existing ts_ls settings", function()
      local diagnostics = require("core.diagnostics")
      local settings = {
        typescript = {
          preferences = {
            importModuleSpecifierPreference = "relative",
          },
        },
      }
      local result = diagnostics.apply_workspace_settings("ts_ls", settings)
      assert.equals("relative", result.typescript.preferences.importModuleSpecifierPreference)
      assert.equals("workspace", result.typescript.diagnosticMode)
    end)

    it("should handle nil settings for pyright", function()
      local diagnostics = require("core.diagnostics")
      local result = diagnostics.apply_workspace_settings("pyright", nil)
      assert.is_table(result)
      assert.equals("workspace", result.python.analysis.diagnosticMode)
    end)

    it("should handle nil settings for ts_ls", function()
      local diagnostics = require("core.diagnostics")
      local result = diagnostics.apply_workspace_settings("ts_ls", nil)
      assert.is_table(result)
      assert.equals("workspace", result.typescript.diagnosticMode)
      assert.equals("workspace", result.javascript.diagnosticMode)
    end)

    it("should return settings unchanged for gopls", function()
      local diagnostics = require("core.diagnostics")
      local settings = { gopls = { gofumpt = true } }
      local result = diagnostics.apply_workspace_settings("gopls", settings)
      assert.same(settings, result)
    end)

    it("should return settings unchanged for rust_analyzer", function()
      local diagnostics = require("core.diagnostics")
      local settings = { ["rust-analyzer"] = { checkOnSave = { command = "clippy" } } }
      local result = diagnostics.apply_workspace_settings("rust_analyzer", settings)
      assert.same(settings, result)
    end)

    it("should return settings unchanged for lua_ls", function()
      local diagnostics = require("core.diagnostics")
      local settings = { Lua = { diagnostics = { globals = { "vim" } } } }
      local result = diagnostics.apply_workspace_settings("lua_ls", settings)
      assert.same(settings, result)
    end)

    it("should return settings unchanged for unknown server", function()
      local diagnostics = require("core.diagnostics")
      local settings = { custom = { option = true } }
      local result = diagnostics.apply_workspace_settings("unknown_server", settings)
      assert.same(settings, result)
    end)
  end)

  describe("setup", function()
    it("should run without error", function()
      local diagnostics = require("core.diagnostics")
      assert.has_no.errors(function()
        diagnostics.setup()
      end)
    end)

    it("should call setup_display", function()
      local diagnostics = require("core.diagnostics")
      diagnostics.setup()
      local state = helper.vim_mock.get_state()
      assert.is_not_nil(state.diagnostic_config)
    end)

    it("can be called multiple times without error", function()
      local diagnostics = require("core.diagnostics")
      assert.has_no.errors(function()
        diagnostics.setup()
        diagnostics.setup()
      end)
    end)
  end)

  describe("integration with workspace config files", function()
    it("should respect pyproject.toml settings via diagnosticMode", function()
      local diagnostics = require("core.diagnostics")
      -- When diagnosticMode is "workspace", pyright reads pyproject.toml
      local settings = diagnostics.apply_workspace_settings("pyright", {})
      assert.equals("workspace", settings.python.analysis.diagnosticMode)
    end)

    it("should respect tsconfig.json settings via diagnosticMode", function()
      local diagnostics = require("core.diagnostics")
      -- When diagnosticMode is "workspace", ts_ls reads tsconfig.json
      local settings = diagnostics.apply_workspace_settings("ts_ls", {})
      assert.equals("workspace", settings.typescript.diagnosticMode)
    end)
  end)
end)

-- Helper function for tests
function vim.tbl_keys(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end
