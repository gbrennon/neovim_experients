-- Tests for plugins/mason.lua
local spec_helper = require("spec_helper")

describe("plugins.mason", function()
  local spec

  local function make_mason_mock()
    local mock = { _setup_opts = nil, setup_called = false }
    mock.setup = function(opts)
      mock.setup_called = true
      mock._setup_opts = opts
    end
    return mock
  end

  local mason_mock

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.mason"] = nil
    package.loaded["mason"] = nil

    mason_mock = make_mason_mock()
    package.loaded["mason"] = mason_mock

    spec = require("plugins.mason")
  end)

  after_each(function()
    package.loaded["plugins.mason"] = nil
    package.loaded["mason"] = nil
  end)

  --------------------------------------------------------------------------
  -- Plugin spec structure
  --------------------------------------------------------------------------

  describe("plugin spec", function()
    it("should return a valid lazy.nvim spec", function()
      assert.is_table(spec)
      assert.equals("williamboman/mason.nvim", spec[1])
    end)

    it("should have a build command", function()
      assert.equals(":MasonUpdate", spec.build)
    end)

    it("should have a config function", function()
      assert.is_function(spec.config)
    end)
  end)

  --------------------------------------------------------------------------
  -- config function
  --------------------------------------------------------------------------

  describe("config function", function()
    it("should run without error", function()
      assert.has_no.errors(function() spec.config() end)
    end)

    it("should call mason.setup", function()
      spec.config()
      assert.is_true(mason_mock.setup_called)
    end)
  end)
end)
