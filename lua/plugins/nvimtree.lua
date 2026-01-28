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
  },
}
