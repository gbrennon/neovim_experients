return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen", "NvimTreeClose" },
  opts = {
    on_attach = require("core.keymaps").nvimtree_on_attach,
    view = {
      width = 30,
    },
    renderer = {
      icons = {
        show = {
          git = true,
          folder = true,
          file = true,
          folder_arrow = true,
        },
      },
    },
    filters = {
      dotfiles = false,
    },
    filesystem_watchers = {
      enable = true,
      debounce_delay = 50,
      ignore_dirs = {
        "node_modules",
        ".git",
        ".venv",
        "__pycache__",
        "target",
      },
    },
    actions = {
      file_popup = {
        open_win_config = {
          col = 1,
          row = 1,
          relative = "cursor",
          border = "shadow",
          style = "minimal",
        },
      },
    },
    live_filter = {
      prefix = "[FILTER]: ",
      always_show_folders = true,
    },
  },
}
