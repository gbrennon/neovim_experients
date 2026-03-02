-- Tests for disabled / lightweight plugin specs:
--   avante.lua, agentic.lua, noice.lua, wrapped.lua
--
-- These plugins have minimal logic — tests focus on spec correctness
-- so regressions in config are caught before runtime.

local spec_helper = require("spec_helper")

--------------------------------------------------------------------------
-- avante.lua
--------------------------------------------------------------------------

describe("plugins.avante", function()
  local spec

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.avante"] = nil
    spec = require("plugins.avante")
  end)

  after_each(function()
    package.loaded["plugins.avante"] = nil
  end)

  it("should return a valid lazy.nvim spec", function()
    assert.is_table(spec)
    assert.equals("yetone/avante.nvim", spec[1])
  end)

  it("should be disabled", function()
    assert.is_false(spec.enabled)
  end)

  it("should load on VeryLazy", function()
    assert.equals("VeryLazy", spec.event)
  end)

  it("should depend on plenary.nvim", function()
    assert.is_true(vim.tbl_contains(spec.dependencies, "nvim-lua/plenary.nvim"))
  end)

  it("should depend on nui.nvim", function()
    assert.is_true(vim.tbl_contains(spec.dependencies, "MunifTanjim/nui.nvim"))
  end)

  it("should have opts table", function()
    assert.is_table(spec.opts)
  end)

  it("should configure acp provider", function()
    assert.equals("acp", spec.opts.provider)
  end)

  it("should configure acp sub-provider as cline", function()
    assert.is_table(spec.opts.acp)
    assert.equals("cline", spec.opts.acp.provider)
  end)
end)

--------------------------------------------------------------------------
-- agentic.lua
--------------------------------------------------------------------------

describe("plugins.agentic", function()
  local spec

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.agentic"] = nil
    spec = require("plugins.agentic")
  end)

  after_each(function()
    package.loaded["plugins.agentic"] = nil
  end)

  it("should return a valid lazy.nvim spec", function()
    assert.is_table(spec)
    assert.equals("carlos-algms/agentic.nvim", spec[1])
  end)

  it("should be disabled", function()
    assert.is_false(spec.enabled)
  end)

  it("should have opts table", function()
    assert.is_table(spec.opts)
  end)

  it("should configure cline-acp provider", function()
    assert.equals("cline-acp", spec.opts.provider)
  end)

  it("should configure acp_providers", function()
    assert.is_table(spec.opts.acp_providers)
    assert.is_table(spec.opts.acp_providers["cline-acp"])
  end)

  it("should configure cline-acp command as cline", function()
    assert.equals("cline", spec.opts.acp_providers["cline-acp"].command)
  end)

  it("should pass --acp arg to cline", function()
    local args = spec.opts.acp_providers["cline-acp"].args
    assert.is_table(args)
    assert.is_true(vim.tbl_contains(args, "--acp"))
  end)

  it("should define a <leader>a keymap", function()
    assert.is_table(spec.keys)
    assert.equals("<leader>a", spec.keys[1][1])
  end)

  it("<leader>a should work in normal, visual, and insert mode", function()
    local modes = spec.keys[1].mode
    assert.is_table(modes)
    assert.is_true(vim.tbl_contains(modes, "n"))
    assert.is_true(vim.tbl_contains(modes, "v"))
    assert.is_true(vim.tbl_contains(modes, "i"))
  end)

  it("<leader>a handler should be a function", function()
    assert.is_function(spec.keys[1][2])
  end)

  it("<leader>a should have a desc", function()
    assert.is_string(spec.keys[1].desc)
  end)
end)

--------------------------------------------------------------------------
-- noice.lua
--------------------------------------------------------------------------

describe("plugins.noice", function()
  local spec

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.noice"] = nil
    spec = require("plugins.noice")
  end)

  after_each(function()
    package.loaded["plugins.noice"] = nil
  end)

  it("should return a valid lazy.nvim spec", function()
    assert.is_table(spec)
    assert.equals("folke/noice.nvim", spec[1])
  end)

  it("should be disabled", function()
    assert.is_false(spec.enabled)
  end)

  it("should load on VeryLazy", function()
    assert.equals("VeryLazy", spec.event)
  end)

  it("should depend on nvim-notify", function()
    assert.is_true(vim.tbl_contains(spec.dependencies, "rcarriga/nvim-notify"))
  end)

  it("should depend on nui.nvim", function()
    assert.is_true(vim.tbl_contains(spec.dependencies, "MunifTanjim/nui.nvim"))
  end)
end)

--------------------------------------------------------------------------
-- wrapped.lua
--------------------------------------------------------------------------

describe("plugins.wrapped", function()
  local spec

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.wrapped"] = nil
    spec = require("plugins.wrapped")
  end)

  after_each(function()
    package.loaded["plugins.wrapped"] = nil
  end)

  it("should return a valid lazy.nvim spec", function()
    assert.is_table(spec)
    assert.equals("aikhe/wrapped.nvim", spec[1])
  end)

  it("should depend on volt", function()
    assert.is_table(spec.dependencies)
    assert.is_true(vim.tbl_contains(spec.dependencies, "nvzone/volt"))
  end)

  it("should load on WrappedNvim command", function()
    assert.is_table(spec.cmd)
    assert.is_true(vim.tbl_contains(spec.cmd, "WrappedNvim"))
  end)

  it("should have opts table", function()
    assert.is_table(spec.opts)
  end)
end)
