-- Tests for plugins/nvimtree.lua
local spec_helper = require("spec_helper")

describe("plugins.nvimtree", function()
  local spec

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.nvimtree"] = nil
    package.loaded["core.keymaps"] = {
      nvimtree_on_attach = function() end,
    }
    spec = require("plugins.nvimtree")
  end)

  after_each(function()
    package.loaded["plugins.nvimtree"] = nil
    package.loaded["core.keymaps"] = nil
  end)

  --------------------------------------------------------------------------
  -- Plugin spec structure
  --------------------------------------------------------------------------

  describe("plugin spec", function()
    it("should return a valid lazy.nvim spec", function()
      assert.is_table(spec)
      assert.equals("nvim-tree/nvim-tree.lua", spec[1])
    end)

    it("should depend on nvim-web-devicons", function()
      assert.is_true(vim.tbl_contains(spec.dependencies, "nvim-tree/nvim-web-devicons"))
    end)

    it("should have opts table", function()
      assert.is_table(spec.opts)
    end)

    local expected_cmds = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen", "NvimTreeClose" }
    for _, cmd in ipairs(expected_cmds) do
      it("should lazy-load on " .. cmd .. " command", function()
        assert.is_true(vim.tbl_contains(spec.cmd, cmd))
      end)
    end
  end)

  --------------------------------------------------------------------------
  -- opts
  --------------------------------------------------------------------------

  describe("opts.on_attach", function()
    it("should be a function", function()
      assert.is_function(spec.opts.on_attach)
    end)

    it("should be wired to core.keymaps.nvimtree_on_attach", function()
      local keymaps = require("core.keymaps")
      assert.equals(keymaps.nvimtree_on_attach, spec.opts.on_attach)
    end)
  end)

  describe("opts.view", function()
    it("should be a table", function()
      assert.is_table(spec.opts.view)
    end)

    it("should have width of 30", function()
      assert.equals(30, spec.opts.view.width)
    end)
  end)

  describe("opts.renderer.icons.show", function()
    it("should be a table", function()
      assert.is_table(spec.opts.renderer)
      assert.is_table(spec.opts.renderer.icons)
      assert.is_table(spec.opts.renderer.icons.show)
    end)

    local icon_flags = { "git", "folder", "file", "folder_arrow" }
    for _, flag in ipairs(icon_flags) do
      it("should show " .. flag .. " icons", function()
        assert.is_true(spec.opts.renderer.icons.show[flag])
      end)
    end
  end)

  describe("opts.filters", function()
    it("should be a table", function()
      assert.is_table(spec.opts.filters)
    end)

    it("should show dotfiles (dotfiles = false)", function()
      assert.is_false(spec.opts.filters.dotfiles)
    end)
  end)

  describe("opts.filesystem_watchers", function()
    it("should be a table", function()
      assert.is_table(spec.opts.filesystem_watchers)
    end)

    it("should be enabled", function()
      assert.is_true(spec.opts.filesystem_watchers.enable)
    end)

    it("should have debounce_delay of 50ms", function()
      assert.equals(50, spec.opts.filesystem_watchers.debounce_delay)
    end)

    it("should ignore node_modules", function()
      assert.is_true(
        vim.tbl_contains(spec.opts.filesystem_watchers.ignore_dirs, "node_modules")
      )
    end)

    it("should ignore .git", function()
      assert.is_true(
        vim.tbl_contains(spec.opts.filesystem_watchers.ignore_dirs, ".git")
      )
    end)

    it("should ignore .venv", function()
      assert.is_true(
        vim.tbl_contains(spec.opts.filesystem_watchers.ignore_dirs, ".venv")
      )
    end)

    it("should ignore __pycache__", function()
      assert.is_true(
        vim.tbl_contains(spec.opts.filesystem_watchers.ignore_dirs, "__pycache__")
      )
    end)
  end)

  describe("opts.actions.file_popup", function()
    it("should be a table", function()
      assert.is_table(spec.opts.actions)
      assert.is_table(spec.opts.actions.file_popup)
    end)

    it("should configure open_win_config", function()
      local cfg = spec.opts.actions.file_popup.open_win_config
      assert.is_table(cfg)
      assert.equals("cursor", cfg.relative)
      assert.equals("shadow", cfg.border)
      assert.equals("minimal", cfg.style)
    end)
  end)

  describe("opts.live_filter", function()
    it("should be a table", function()
      assert.is_table(spec.opts.live_filter)
    end)

    it("should always show folders", function()
      assert.is_true(spec.opts.live_filter.always_show_folders)
    end)

    it("should have a prefix string", function()
      assert.is_string(spec.opts.live_filter.prefix)
    end)
  end)
end)
