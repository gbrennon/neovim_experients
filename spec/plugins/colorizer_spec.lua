-- Tests for plugins/colorizer.lua
local spec_helper = require("spec_helper")

describe("plugins.colorizer", function()
  local spec, M

  local function make_colorizer_mock()
    local mock = { _setup_config = nil, setup_called = false }
    mock.setup = function(cfg)
      mock.setup_called = true
      mock._setup_config = cfg
    end
    return mock
  end

  local colorizer_mock

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.colorizer"] = nil
    package.loaded["colorizer"] = nil

    colorizer_mock = make_colorizer_mock()
    package.loaded["colorizer"] = colorizer_mock

    spec = require("plugins.colorizer")
    M = spec._module
  end)

  after_each(function()
    package.loaded["plugins.colorizer"] = nil
    package.loaded["colorizer"] = nil
  end)

  --------------------------------------------------------------------------
  -- Plugin spec structure
  --------------------------------------------------------------------------

  describe("plugin spec", function()
    it("should return a valid lazy.nvim spec", function()
      assert.is_table(spec)
      assert.equals("NvChad/nvim-colorizer.lua", spec[1])
    end)

    it("should not be lazy-loaded", function()
      assert.is_false(spec.lazy)
    end)

    it("should have config function", function()
      assert.is_function(spec.config)
    end)

    it("should expose _module for testing", function()
      assert.is_table(spec._module)
    end)
  end)

  --------------------------------------------------------------------------
  -- default_options
  --------------------------------------------------------------------------

  describe("_module.default_options", function()
    it("should be a table", function()
      assert.is_table(M.default_options)
    end)

    local truthy_flags = {
      "RGB", "RRGGBB", "RRGGBBAA", "AARRGGBB",
      "rgb_fn", "hsl_fn", "css", "css_fn",
    }
    for _, flag in ipairs(truthy_flags) do
      it("should enable " .. flag, function()
        assert.is_true(M.default_options[flag])
      end)
    end

    it("should disable names (avoid false positives on words)", function()
      assert.is_false(M.default_options.names)
    end)

    it("should disable tailwind", function()
      assert.is_false(M.default_options.tailwind)
    end)

    it("should set mode to background", function()
      assert.equals("background", M.default_options.mode)
    end)

    it("should have sass configuration", function()
      assert.is_table(M.default_options.sass)
      assert.is_false(M.default_options.sass.enable)
    end)

    it("should set a virtualtext string", function()
      assert.is_string(M.default_options.virtualtext)
      assert.is_true(#M.default_options.virtualtext > 0)
    end)

    it("should set always_update to false", function()
      assert.is_false(M.default_options.always_update)
    end)
  end)

  --------------------------------------------------------------------------
  -- config function
  --------------------------------------------------------------------------

  describe("config / _module.config", function()
    it("should run without error", function()
      assert.has_no.errors(function() M.config() end)
    end)

    it("should call colorizer.setup", function()
      M.config()
      assert.is_true(colorizer_mock.setup_called)
    end)

    it("should apply to all filetypes (*)", function()
      M.config()
      assert.equals("*", colorizer_mock._setup_config.filetypes[1])
    end)

    it("should pass default_options as user_default_options", function()
      M.config()
      assert.same(M.default_options, colorizer_mock._setup_config.user_default_options)
    end)

    it("spec.config should delegate to _module.config", function()
      spec.config()
      assert.is_true(colorizer_mock.setup_called)
    end)
  end)
end)
