return {
  "yetone/avante.nvim",
  enabled = false,
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    provider = "acp",
    acp = {
      provider = "cline",
    },
  },
}
