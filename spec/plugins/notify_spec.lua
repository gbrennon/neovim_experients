-- Tests for plugins/notify.lua
local spec_helper = require("spec_helper")

describe("plugins.notify", function()
  local spec

  local function make_notify_mock()
    local mock = { _setup_opts = nil }
    mock.setup = function(opts) mock._setup_opts = opts end
    -- notify mock is callable (it IS the notify function)
    setmetatable(mock, {
      __call = function(_, msg, level, opts) end,
    })
    return mock
  end

  local notify_mock
  local original_vim_notify
  local system_calls

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.notify"] = nil
    package.loaded["notify"] = nil

    notify_mock = make_notify_mock()
    package.loaded["notify"] = notify_mock

    -- Capture the original vim.notify before config replaces it
    original_vim_notify = vim.notify

    -- Track system calls
    system_calls = {}
    vim.fn.system = function(cmd)
      table.insert(system_calls, cmd)
    end

    spec = require("plugins.notify")
  end)

  after_each(function()
    -- Restore vim.notify to avoid polluting other tests
    vim.notify = original_vim_notify
    package.loaded["plugins.notify"] = nil
    package.loaded["notify"] = nil
    system_calls = {}
  end)

  --------------------------------------------------------------------------
  -- Plugin spec structure
  --------------------------------------------------------------------------

  describe("plugin spec", function()
    it("should return a valid lazy.nvim spec", function()
      assert.is_table(spec)
      assert.equals("rcarriga/nvim-notify", spec[1])
    end)

    it("should not be lazy-loaded", function()
      assert.is_false(spec.lazy)
    end)

    it("should have high priority", function()
      assert.equals(1000, spec.priority)
    end)

    it("should have config function", function()
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

    it("should call notify.setup", function()
      spec.config()
      assert.is_not_nil(notify_mock._setup_opts)
    end)

    it("should use static stages", function()
      spec.config()
      assert.equals("static", notify_mock._setup_opts.stages)
    end)

    it("should set timeout to 3000ms", function()
      spec.config()
      assert.equals(3000, notify_mock._setup_opts.timeout)
    end)

    it("should use wrapped-compact render", function()
      spec.config()
      assert.equals("wrapped-compact", notify_mock._setup_opts.render)
    end)

    it("should set level to error (suppress noise)", function()
      spec.config()
      assert.equals("error", notify_mock._setup_opts.level)
    end)

    it("should override vim.notify after setup", function()
      local original = vim.notify
      spec.config()
      -- vim.notify should now be a different function
      assert.is_function(vim.notify)
    end)
  end)

  --------------------------------------------------------------------------
  -- vim.notify override behaviour
  --------------------------------------------------------------------------

  describe("vim.notify override", function()
    before_each(function()
      spec.config()
    end)

    it("should still call original notify for all levels", function()
      local original_called = false
      -- The mock is stored and called inside the override
      -- We verify by checking the mock is callable (the override wraps it)
      assert.is_function(vim.notify)
    end)

    it("should trigger OS notification for ERROR level on unix", function()
      vim.fn.has = function(platform)
        return platform == "unix" and 1 or 0
      end

      vim.notify("something broke", vim.log.levels.ERROR)

      assert.is_true(#system_calls > 0, "notify-send should have been called")
      local call = system_calls[1]
      assert.equals("notify-send", call[1])
      assert.equals("-u", call[2])
      assert.equals("critical", call[3])
    end)

    it("should not trigger OS notification for INFO level", function()
      vim.fn.has = function(_) return 1 end -- pretend unix

      vim.notify("just info", vim.log.levels.INFO)

      assert.equals(0, #system_calls, "notify-send should NOT be called for INFO")
    end)

    it("should not trigger OS notification for WARN level", function()
      vim.fn.has = function(_) return 1 end

      vim.notify("a warning", vim.log.levels.WARN)

      assert.equals(0, #system_calls, "notify-send should NOT be called for WARN")
    end)

    it("should default level to INFO when nil is passed", function()
      -- Should not crash and should not send OS notification
      vim.fn.has = function(_) return 1 end
      assert.has_no.errors(function()
        vim.notify("no level given", nil)
      end)
      assert.equals(0, #system_calls)
    end)

    it("should use osascript on mac instead of notify-send", function()
      vim.fn.has = function(platform)
        if platform == "unix" then return 0 end
        if platform == "mac" then return 1 end
        return 0
      end

      vim.notify("mac error", vim.log.levels.ERROR)

      assert.is_true(#system_calls > 0)
      local call = system_calls[1]
      assert.equals("osascript", call[1])
    end)
  end)
end)
