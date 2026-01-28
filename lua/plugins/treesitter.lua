return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "python",
      "lua",
      "bash",
      "json",
      "yaml",
      "toml",
      "markdown",
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },
}
