-- Tests for plugins/gitsigns.lua
local spec_helper = require("spec_helper")

describe("plugins.gitsigns", function()
  before_each(function()
    spec_helper.reset_vim_mock()
    -- Mock gitsigns API
    package.loaded["gitsigns"] = {
      setup = function(opts)
        vim.g._gitsigns_config = opts
      end,
      next_hunk = function() end,
      prev_hunk = function() end,
      stage_hunk = function() end,
      reset_hunk = function() end,
      stage_buffer = function() end,
      undo_stage_hunk = function() end,
      reset_buffer = function() end,
      preview_hunk = function() end,
      blame_line = function() end,
      diffthis = function() end,
    }
  end)

  after_each(function()
    package.loaded["gitsigns"] = nil
    vim.g._gitsigns_config = nil
  end)

  describe("plugin spec", function()
    it("should return a valid lazy.nvim plugin spec", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec)
      assert.equals("lewis6991/gitsigns.nvim", spec[1])
    end)

    it("should have event trigger", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec.event)
    end)

    it("should trigger on BufReadPre", function()
      local spec = require("plugins.gitsigns")
      assert.is_true(vim.tbl_contains(spec.event, "BufReadPre"))
    end)

    it("should trigger on BufNewFile", function()
      local spec = require("plugins.gitsigns")
      assert.is_true(vim.tbl_contains(spec.event, "BufNewFile"))
    end)

    it("should have config function", function()
      local spec = require("plugins.gitsigns")
      assert.is_function(spec.config)
    end)

    it("should expose _module for testing", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module)
    end)
  end)

  describe("_module.signs_config", function()
    it("should define signs configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.signs_config)
    end)

    it("should have add sign configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.signs_config.add)
      assert.is_string(spec._module.signs_config.add.text)
    end)

    it("should have change sign configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.signs_config.change)
      assert.is_string(spec._module.signs_config.change.text)
    end)

    it("should have delete sign configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.signs_config.delete)
      assert.is_string(spec._module.signs_config.delete.text)
    end)

    it("should have topdelete sign configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.signs_config.topdelete)
      assert.is_string(spec._module.signs_config.topdelete.text)
    end)

    it("should have changedelete sign configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.signs_config.changedelete)
      assert.is_string(spec._module.signs_config.changedelete.text)
    end)

    it("should have untracked sign configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.signs_config.untracked)
      assert.is_string(spec._module.signs_config.untracked.text)
    end)
  end)

  describe("_module.keymaps", function()
    it("should define keymaps configuration", function()
      local spec = require("plugins.gitsigns")
      assert.is_table(spec._module.keymaps)
    end)

    it("should have next_hunk keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.next_hunk)
      assert.equals("]c", spec._module.keymaps.next_hunk)
    end)

    it("should have prev_hunk keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.prev_hunk)
      assert.equals("[c", spec._module.keymaps.prev_hunk)
    end)

    it("should have stage_hunk keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.stage_hunk)
      assert.equals("<leader>hs", spec._module.keymaps.stage_hunk)
    end)

    it("should have reset_hunk keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.reset_hunk)
      assert.equals("<leader>hr", spec._module.keymaps.reset_hunk)
    end)

    it("should have stage_buffer keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.stage_buffer)
      assert.equals("<leader>hS", spec._module.keymaps.stage_buffer)
    end)

    it("should have undo_stage_hunk keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.undo_stage_hunk)
      assert.equals("<leader>hu", spec._module.keymaps.undo_stage_hunk)
    end)

    it("should have reset_buffer keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.reset_buffer)
      assert.equals("<leader>hR", spec._module.keymaps.reset_buffer)
    end)

    it("should have preview_hunk keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.preview_hunk)
      assert.equals("<leader>hp", spec._module.keymaps.preview_hunk)
    end)

    it("should have blame_line keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.blame_line)
      assert.equals("<leader>hb", spec._module.keymaps.blame_line)
    end)

    it("should have diff_this keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.diff_this)
      assert.equals("<leader>hd", spec._module.keymaps.diff_this)
    end)

    it("should have diff_this_cached keymap", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.diff_this_cached)
      assert.equals("<leader>hD", spec._module.keymaps.diff_this_cached)
    end)

    it("should have select_hunk text object", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec._module.keymaps.select_hunk)
      assert.equals("ih", spec._module.keymaps.select_hunk)
    end)
  end)

  describe("_module.on_attach", function()
    it("should be a function", function()
      local spec = require("plugins.gitsigns")
      assert.is_function(spec._module.on_attach)
    end)

    it("should set up navigation keymaps", function()
      local spec = require("plugins.gitsigns")
      package.loaded.gitsigns = {
        next_hunk = function() end,
        prev_hunk = function() end,
        stage_hunk = function() end,
        reset_hunk = function() end,
        stage_buffer = function() end,
        undo_stage_hunk = function() end,
        reset_buffer = function() end,
        preview_hunk = function() end,
        blame_line = function() end,
        diffthis = function() end,
      }

      spec._module.on_attach(1)
      local state = spec_helper.vim_mock.get_state()

      -- Check next hunk keymap
      local next_keymap = vim.keymap._get_keymap("n", "]c")
      assert.is_not_nil(next_keymap)
      assert.equals(1, next_keymap.buffer)

      -- Check prev hunk keymap
      local prev_keymap = vim.keymap._get_keymap("n", "[c")
      assert.is_not_nil(prev_keymap)
      assert.equals(1, prev_keymap.buffer)
    end)

    it("should set up action keymaps", function()
      local spec = require("plugins.gitsigns")
      package.loaded.gitsigns = {
        next_hunk = function() end,
        prev_hunk = function() end,
        stage_hunk = function() end,
        reset_hunk = function() end,
        stage_buffer = function() end,
        undo_stage_hunk = function() end,
        reset_buffer = function() end,
        preview_hunk = function() end,
        blame_line = function() end,
        diffthis = function() end,
      }

      spec._module.on_attach(1)

      -- Check stage hunk keymap
      local stage_keymap = vim.keymap._get_keymap("n", "<leader>hs")
      assert.is_not_nil(stage_keymap)
      assert.equals(1, stage_keymap.buffer)

      -- Check reset hunk keymap
      local reset_keymap = vim.keymap._get_keymap("n", "<leader>hr")
      assert.is_not_nil(reset_keymap)
      assert.equals(1, reset_keymap.buffer)

      -- Check preview hunk keymap
      local preview_keymap = vim.keymap._get_keymap("n", "<leader>hp")
      assert.is_not_nil(preview_keymap)
      assert.equals(1, preview_keymap.buffer)

      -- Check blame line keymap
      local blame_keymap = vim.keymap._get_keymap("n", "<leader>hb")
      assert.is_not_nil(blame_keymap)
      assert.equals(1, blame_keymap.buffer)
    end)

    it("should set up visual mode keymaps", function()
      local spec = require("plugins.gitsigns")
      package.loaded.gitsigns = {
        next_hunk = function() end,
        prev_hunk = function() end,
        stage_hunk = function() end,
        reset_hunk = function() end,
        stage_buffer = function() end,
        undo_stage_hunk = function() end,
        reset_buffer = function() end,
        preview_hunk = function() end,
        blame_line = function() end,
        diffthis = function() end,
      }

      spec._module.on_attach(1)

      -- Check visual stage hunk keymap
      local vstage_keymap = vim.keymap._get_keymap("v", "<leader>hs")
      assert.is_not_nil(vstage_keymap)
      assert.equals(1, vstage_keymap.buffer)

      -- Check visual reset hunk keymap
      local vreset_keymap = vim.keymap._get_keymap("v", "<leader>hr")
      assert.is_not_nil(vreset_keymap)
      assert.equals(1, vreset_keymap.buffer)
    end)

    it("should set up text object keymaps", function()
      local spec = require("plugins.gitsigns")
      package.loaded.gitsigns = {
        next_hunk = function() end,
        prev_hunk = function() end,
        stage_hunk = function() end,
        reset_hunk = function() end,
        stage_buffer = function() end,
        undo_stage_hunk = function() end,
        reset_buffer = function() end,
        preview_hunk = function() end,
        blame_line = function() end,
        diffthis = function() end,
      }

      spec._module.on_attach(1)

      -- Check operator-pending mode text object
      local op_keymap = vim.keymap._get_keymap("o", "ih")
      assert.is_not_nil(op_keymap)
      assert.equals(1, op_keymap.buffer)

      -- Check visual mode text object
      local x_keymap = vim.keymap._get_keymap("x", "ih")
      assert.is_not_nil(x_keymap)
      assert.equals(1, x_keymap.buffer)
    end)

    it("should set buffer-local keymaps", function()
      local spec = require("plugins.gitsigns")
      package.loaded.gitsigns = {
        next_hunk = function() end,
        prev_hunk = function() end,
        stage_hunk = function() end,
        reset_hunk = function() end,
        stage_buffer = function() end,
        undo_stage_hunk = function() end,
        reset_buffer = function() end,
        preview_hunk = function() end,
        blame_line = function() end,
        diffthis = function() end,
      }

      spec._module.on_attach(42)

      -- Verify all keymaps are buffer-local to buffer 42
      local stage_keymap = vim.keymap._get_keymap("n", "<leader>hs")
      assert.equals(42, stage_keymap.buffer)
    end)
  end)

  describe("_module.config", function()
    it("should be a function", function()
      local spec = require("plugins.gitsigns")
      assert.is_function(spec._module.config)
    end)

    it("should call gitsigns.setup", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_not_nil(vim.g._gitsigns_config)
    end)

    it("should configure signs", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_table(vim.g._gitsigns_config.signs)
      assert.is_table(vim.g._gitsigns_config.signs.add)
      assert.is_table(vim.g._gitsigns_config.signs.change)
      assert.is_table(vim.g._gitsigns_config.signs.delete)
    end)

    it("should enable signcolumn", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_true(vim.g._gitsigns_config.signcolumn)
    end)

    it("should disable numhl by default", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_false(vim.g._gitsigns_config.numhl)
    end)

    it("should disable linehl by default", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_false(vim.g._gitsigns_config.linehl)
    end)

    it("should disable word_diff by default", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_false(vim.g._gitsigns_config.word_diff)
    end)

    it("should configure watch_gitdir", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_table(vim.g._gitsigns_config.watch_gitdir)
      assert.equals(1000, vim.g._gitsigns_config.watch_gitdir.interval)
      assert.is_true(vim.g._gitsigns_config.watch_gitdir.follow_files)
    end)

    it("should attach to untracked files", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_true(vim.g._gitsigns_config.attach_to_untracked)
    end)

    it("should disable current_line_blame by default", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_false(vim.g._gitsigns_config.current_line_blame)
    end)

    it("should configure current_line_blame_opts", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_table(vim.g._gitsigns_config.current_line_blame_opts)
      assert.is_true(vim.g._gitsigns_config.current_line_blame_opts.virt_text)
      assert.equals("eol", vim.g._gitsigns_config.current_line_blame_opts.virt_text_pos)
      assert.equals(1000, vim.g._gitsigns_config.current_line_blame_opts.delay)
    end)

    it("should configure current_line_blame_formatter", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_string(vim.g._gitsigns_config.current_line_blame_formatter)
      assert.truthy(vim.g._gitsigns_config.current_line_blame_formatter:find("<author>"))
    end)

    it("should set sign_priority", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.equals(6, vim.g._gitsigns_config.sign_priority)
    end)

    it("should set update_debounce", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.equals(100, vim.g._gitsigns_config.update_debounce)
    end)

    it("should configure max_file_length", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.equals(40000, vim.g._gitsigns_config.max_file_length)
    end)

    it("should configure preview_config", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_table(vim.g._gitsigns_config.preview_config)
      assert.equals("rounded", vim.g._gitsigns_config.preview_config.border)
      assert.equals("minimal", vim.g._gitsigns_config.preview_config.style)
      assert.equals("cursor", vim.g._gitsigns_config.preview_config.relative)
    end)

    it("should set on_attach callback", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.is_function(vim.g._gitsigns_config.on_attach)
    end)

    it("should use module's on_attach function", function()
      local spec = require("plugins.gitsigns")
      spec._module.config()
      assert.equals(spec._module.on_attach, vim.g._gitsigns_config.on_attach)
    end)
  end)

  describe("config function", function()
    it("should run without error", function()
      local spec = require("plugins.gitsigns")
      assert.has_no.errors(function()
        spec.config()
      end)
    end)

    it("should delegate to _module.config", function()
      local spec = require("plugins.gitsigns")
      spec.config()
      assert.is_not_nil(vim.g._gitsigns_config)
    end)
  end)

  describe("integration", function()
    it("should work with lazy.nvim", function()
      local spec = require("plugins.gitsigns")
      assert.is_string(spec[1])
      assert.is_table(spec.event)
      assert.is_function(spec.config)
    end)

    it("should be loadable via require", function()
      assert.has_no.errors(function()
        require("plugins.gitsigns")
      end)
    end)

    it("should preserve module structure after config", function()
      local spec = require("plugins.gitsigns")
      spec.config()
      assert.is_table(spec._module)
      assert.is_function(spec._module.on_attach)
      assert.is_table(spec._module.signs_config)
      assert.is_table(spec._module.keymaps)
    end)
  end)
end)
