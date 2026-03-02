-- Tests for plugins/which-keys.lua
local spec_helper = require("spec_helper")

describe("plugins.which-key", function()
  local spec

  local function make_which_key_mock()
    local mock = { _show_opts = nil }
    mock.show = function(opts) mock._show_opts = opts end
    return mock
  end

  local wk_mock

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.which-key"] = nil
    package.loaded["which-key"] = nil

    wk_mock = make_which_key_mock()
    package.loaded["which-key"] = wk_mock

    spec = require("plugins.which-key")
  end)

  after_each(function()
    package.loaded["plugins.which-key"] = nil
    package.loaded["which-key"] = nil
  end)

  --------------------------------------------------------------------------
  -- Plugin spec structure
  --------------------------------------------------------------------------

  describe("plugin spec", function()
    it("should return a valid lazy.nvim spec", function()
      assert.is_table(spec)
      assert.equals("folke/which-key.nvim", spec[1])
    end)

    it("should load on VeryLazy event", function()
      assert.equals("VeryLazy", spec.event)
    end)

    it("should have opts table", function()
      assert.is_table(spec.opts)
    end)

    it("should have keys table", function()
      assert.is_table(spec.keys)
    end)
  end)

  --------------------------------------------------------------------------
  -- Keybindings
  --------------------------------------------------------------------------

  describe("keys", function()
    it("should define exactly one keymap", function()
      assert.equals(1, #spec.keys)
    end)

    it("should bind <leader>?", function()
      assert.equals("<leader>?", spec.keys[1][1])
    end)

    it("should have a handler function", function()
      assert.is_function(spec.keys[1][2])
    end)

    it("should have a desc", function()
      assert.is_string(spec.keys[1].desc)
    end)

    it("handler should call which-key.show with global = false", function()
      spec.keys[1][2]()
      assert.is_not_nil(wk_mock._show_opts)
      assert.is_false(wk_mock._show_opts.global)
    end)
  end)
end)
