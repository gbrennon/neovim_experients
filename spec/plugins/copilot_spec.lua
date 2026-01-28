-- Tests for plugins/copilot.lua
local helper = require("spec.spec_helper")

describe("plugins.copilot", function()
  before_each(function()
    helper.before_each()
    -- Mock copilot
    package.loaded["copilot"] = {
      setup = function() end,
    }
  end)

  after_each(function()
    package.loaded["copilot"] = nil
  end)

  describe("plugin spec", function()
    it("should return a valid lazy.nvim plugin spec", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec)
      assert.equals("zbirenbaum/copilot.lua", spec[1])
    end)

    it("should have event trigger", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec.event)
    end)

    it("should trigger on BufReadPre", function()
      local spec = require("plugins.copilot")
      assert.is_true(vim.tbl_contains(spec.event, "BufReadPre"))
    end)

    it("should trigger on BufNewFile", function()
      local spec = require("plugins.copilot")
      assert.is_true(vim.tbl_contains(spec.event, "BufNewFile"))
    end)

    it("should have config function", function()
      local spec = require("plugins.copilot")
      assert.is_function(spec.config)
    end)

    it("should expose _module for testing", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec._module)
    end)
  end)

  describe("_module.panel_config", function()
    it("should be a table", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec._module.panel_config)
    end)

    it("should be enabled", function()
      local spec = require("plugins.copilot")
      assert.is_true(spec._module.panel_config.enabled)
    end)

    it("should have auto_refresh enabled", function()
      local spec = require("plugins.copilot")
      assert.is_true(spec._module.panel_config.auto_refresh)
    end)

    it("should have keymap configuration", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec._module.panel_config.keymap)
    end)

    it("should have jump_prev keymap", function()
      local spec = require("plugins.copilot")
      assert.equals("[[", spec._module.panel_config.keymap.jump_prev)
    end)

    it("should have jump_next keymap", function()
      local spec = require("plugins.copilot")
      assert.equals("]]", spec._module.panel_config.keymap.jump_next)
    end)

    it("should have accept keymap", function()
      local spec = require("plugins.copilot")
      assert.equals("<CR>", spec._module.panel_config.keymap.accept)
    end)

    it("should have layout configuration", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec._module.panel_config.layout)
    end)

    it("should have bottom position", function()
      local spec = require("plugins.copilot")
      assert.equals("bottom", spec._module.panel_config.layout.position)
    end)

    it("should have ratio of 0.4", function()
      local spec = require("plugins.copilot")
      assert.equals(0.4, spec._module.panel_config.layout.ratio)
    end)
  end)

  describe("_module.suggestion_config", function()
    it("should be a table", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec._module.suggestion_config)
    end)

    it("should be enabled", function()
      local spec = require("plugins.copilot")
      assert.is_true(spec._module.suggestion_config.enabled)
    end)

    it("should have auto_trigger enabled", function()
      local spec = require("plugins.copilot")
      assert.is_true(spec._module.suggestion_config.auto_trigger)
    end)

    it("should have debounce of 75", function()
      local spec = require("plugins.copilot")
      assert.equals(75, spec._module.suggestion_config.debounce)
    end)

    it("should have keymap configuration", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec._module.suggestion_config.keymap)
    end)

    it("should have accept keymap as meta y", function()
      local spec = require("plugins.copilot")
      assert.equals("<M-y>", spec._module.suggestion_config.keymap.accept)
    end)
  end)

  describe("_module.filetypes", function()
    it("should be a table", function()
      local spec = require("plugins.copilot")
      assert.is_table(spec._module.filetypes)
    end)

    it("should disable yaml", function()
      local spec = require("plugins.copilot")
      assert.is_false(spec._module.filetypes.yaml)
    end)

    it("should disable markdown", function()
      local spec = require("plugins.copilot")
      assert.is_false(spec._module.filetypes.markdown)
    end)

    it("should disable help", function()
      local spec = require("plugins.copilot")
      assert.is_false(spec._module.filetypes.help)
    end)

    it("should disable gitcommit", function()
      local spec = require("plugins.copilot")
      assert.is_false(spec._module.filetypes.gitcommit)
    end)

    it("should disable gitrebase", function()
      local spec = require("plugins.copilot")
      assert.is_false(spec._module.filetypes.gitrebase)
    end)
  end)

  describe("config function", function()
    it("should run without error", function()
      local spec = require("plugins.copilot")
      assert.has_no.errors(function()
        spec.config()
      end)
    end)

    it("should call copilot.setup", function()
      local setup_called = false
      package.loaded["copilot"] = {
        setup = function()
          setup_called = true
        end,
      }

      local spec = require("plugins.copilot")
      spec.config()
      assert.is_true(setup_called)
    end)

    it("should pass correct options to setup", function()
      local passed_opts = nil
      package.loaded["copilot"] = {
        setup = function(opts)
          passed_opts = opts
        end,
      }

      local spec = require("plugins.copilot")
      spec.config()

      assert.is_not_nil(passed_opts)
      assert.is_table(passed_opts.panel)
      assert.is_table(passed_opts.suggestion)
      assert.is_table(passed_opts.filetypes)
    end)

    it("should set copilot_node_command to node", function()
      local passed_opts = nil
      package.loaded["copilot"] = {
        setup = function(opts)
          passed_opts = opts
        end,
      }

      local spec = require("plugins.copilot")
      spec.config()

      assert.equals("node", passed_opts.copilot_node_command)
    end)
  end)
end)
