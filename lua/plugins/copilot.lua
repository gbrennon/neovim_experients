-- GitHub Copilot Configuration

local M = {}

M.panel_config = {
  enabled = true,
  auto_refresh = true,
  keymap = {
    jump_prev = "[[",
    jump_next = "]]",
    accept = "<CR>",
    refresh = "gr",
    open = "<M-CR>",
  },
  layout = {
    position = "bottom",
    ratio = 0.4,
  },
}

M.suggestion_config = {
  enabled = true,
  auto_trigger = true,
  debounce = 75,
  keymap = {
    accept = "<Tab>",
    accept_word = false,
    accept_line = false,
    next = "<M-k>",
    prev = "<M-j>",
    dismiss = "<M-e>",
  },
}

M.filetypes = {
  yaml = true,
  markdown = true,
  help = false,
  gitcommit = true,
  gitrebase = false,
  hgcommit = false,
  svn = false,
  cvs = false,
  ["."] = false,
}

function M.config()
  require("copilot").setup({
    panel = M.panel_config,
    suggestion = M.suggestion_config,
    filetypes = M.filetypes,
    copilot_node_command = "node",
    server_opts_overrides = {},
  })
end

-- Plugin spec for lazy.nvim
return {
  "zbirenbaum/copilot.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = M.config,
  _module = M,
}
