-- Tests for plugins/treesitter.lua
local spec_helper = require("spec_helper")

describe("plugins.treesitter", function()
  local spec

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.treesitter"] = nil
    spec = require("plugins.treesitter")
  end)

  after_each(function()
    package.loaded["plugins.treesitter"] = nil
  end)

  --------------------------------------------------------------------------
  -- Plugin spec structure
  --------------------------------------------------------------------------

  describe("plugin spec", function()
    it("should return a valid lazy.nvim spec", function()
      assert.is_table(spec)
      assert.equals("nvim-treesitter/nvim-treesitter", spec[1])
    end)

    it("should have a build command", function()
      assert.equals(":TSUpdate", spec.build)
    end)

    it("should trigger on BufReadPost", function()
      assert.is_true(vim.tbl_contains(spec.event, "BufReadPost"))
    end)

    it("should trigger on BufNewFile", function()
      assert.is_true(vim.tbl_contains(spec.event, "BufNewFile"))
    end)

    it("should have opts table", function()
      assert.is_table(spec.opts)
    end)
  end)

  --------------------------------------------------------------------------
  -- ensure_installed parsers
  --------------------------------------------------------------------------

  describe("opts.ensure_installed", function()
    it("should be a table", function()
      assert.is_table(spec.opts.ensure_installed)
    end)

    local expected_parsers = {
      "python", "lua", "bash", "json", "yaml", "toml", "markdown",
    }

    for _, parser in ipairs(expected_parsers) do
      it("should install " .. parser .. " parser", function()
        assert.is_true(
          vim.tbl_contains(spec.opts.ensure_installed, parser),
          parser .. " missing from ensure_installed"
        )
      end)
    end
  end)

  --------------------------------------------------------------------------
  -- Feature flags
  --------------------------------------------------------------------------

  describe("opts.highlight", function()
    it("should be a table", function()
      assert.is_table(spec.opts.highlight)
    end)

    it("should be enabled", function()
      assert.is_true(spec.opts.highlight.enable)
    end)
  end)

  describe("opts.indent", function()
    it("should be a table", function()
      assert.is_table(spec.opts.indent)
    end)

    it("should be enabled", function()
      assert.is_true(spec.opts.indent.enable)
    end)
  end)
end)
