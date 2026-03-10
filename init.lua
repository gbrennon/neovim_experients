-- Neovim Configuration Entry Point

-- Add config directory to runtime path so require() can find lua/ modules
local config_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
vim.opt.rtp:prepend(config_path)
package.path = config_path .. "/lua/?.lua;" .. config_path .. "/lua/?/init.lua;" .. package.path

-- Load core modules
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins", {
  defaults = { run = true },
  change_detection = { notify = true },
})
