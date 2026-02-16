return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-notify",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("noice").setup({
      lsp = {
        progress = {
          enabled = true,
        },
        hover = {
          enabled = true,
        },
        signature = {
          enabled = true,
        },
      },

      routes = {
        -- Route diagnostics as notifications
        {
          filter = {
            event = "lsp",
            kind = "diagnostics",
            min_severity = vim.diagnostic.severity.WARN,
          },
          opts = {
            skip = false,
          },
        },

        -- Reduce noise from trivial messages
        {
          filter = {
            event = "msg_show",
            find = "written",
          },
          opts = { skip = true },
        },
      },

      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    })
  end,
}
