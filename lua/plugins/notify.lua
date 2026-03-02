return {
  "rcarriga/nvim-notify",
  lazy = false,
  priority = 1000,
  config = function()
    local notify = require("notify")

    notify.setup({
      stages = "static",
      timeout = 3000,
      render = "wrapped-compact",
      level = "error",
    })

    -- Override vim.notify to use OS notifications for errors
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
      level = level or vim.log.levels.INFO
      opts = opts or {}

      -- Only show errors as OS notifications
      if level == vim.log.levels.ERROR then
        local title = "Neovim Error"
        if vim.fn.has("unix") == 1 then
          -- Linux: use notify-send
          vim.fn.system({ "notify-send", "-u", "critical", title, msg })
        elseif vim.fn.has("mac") == 1 then
          -- macOS: use osascript
          vim.fn.system({
            "osascript",
            "-e",
            string.format('display notification "%s" with title "%s"', msg, title),
          })
        end
      end

      -- Still show in vim for debugging
      original_notify(msg, level, opts)
    end
  end,
}
