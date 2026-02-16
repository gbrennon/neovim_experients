-- Git signs in the gutter
-- Shows added, modified, and deleted lines with visual indicators

local M = {}

M.signs_config = {
  add = { text = "│" },
  change = { text = "│" },
  delete = { text = "_" },
  topdelete = { text = "‾" },
  changedelete = { text = "~" },
  untracked = { text = "┆" },
}

M.keymaps = {
  -- Navigation between hunks
  next_hunk = "]c",
  prev_hunk = "[c",

  -- Actions
  stage_hunk = "<leader>hs",
  reset_hunk = "<leader>hr",
  stage_buffer = "<leader>hS",
  undo_stage_hunk = "<leader>hu",
  reset_buffer = "<leader>hR",
  preview_hunk = "<leader>hp",
  blame_line = "<leader>hb",
  diff_this = "<leader>hd",
  diff_this_cached = "<leader>hD",

  -- Text object
  select_hunk = "ih",
}

function M.on_attach(bufnr)
  local gs = package.loaded.gitsigns
  local map = vim.keymap.set

  -- Navigation
  map("n", M.keymaps.next_hunk, function()
    if vim.wo.diff then
      return M.keymaps.next_hunk
    end
    vim.schedule(function()
      gs.next_hunk()
    end)
    return "<Ignore>"
  end, { expr = true, buffer = bufnr, desc = "Next Git Hunk" })

  map("n", M.keymaps.prev_hunk, function()
    if vim.wo.diff then
      return M.keymaps.prev_hunk
    end
    vim.schedule(function()
      gs.prev_hunk()
    end)
    return "<Ignore>"
  end, { expr = true, buffer = bufnr, desc = "Previous Git Hunk" })

  -- Actions
  map("n", M.keymaps.stage_hunk, gs.stage_hunk, { buffer = bufnr, desc = "Stage Hunk" })
  map("n", M.keymaps.reset_hunk, gs.reset_hunk, { buffer = bufnr, desc = "Reset Hunk" })
  map("v", M.keymaps.stage_hunk, function()
    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, { buffer = bufnr, desc = "Stage Hunk" })
  map("v", M.keymaps.reset_hunk, function()
    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, { buffer = bufnr, desc = "Reset Hunk" })
  map("n", M.keymaps.stage_buffer, gs.stage_buffer, { buffer = bufnr, desc = "Stage Buffer" })
  map("n", M.keymaps.undo_stage_hunk, gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo Stage Hunk" })
  map("n", M.keymaps.reset_buffer, gs.reset_buffer, { buffer = bufnr, desc = "Reset Buffer" })
  map("n", M.keymaps.preview_hunk, gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
  map("n", M.keymaps.blame_line, function()
    gs.blame_line({ full = true })
  end, { buffer = bufnr, desc = "Blame Line" })
  map("n", M.keymaps.diff_this, gs.diffthis, { buffer = bufnr, desc = "Diff This" })
  map("n", M.keymaps.diff_this_cached, function()
    gs.diffthis("~")
  end, { buffer = bufnr, desc = "Diff This (Cached)" })

  -- Text object
  map({ "o", "x" }, M.keymaps.select_hunk, ":<C-U>Gitsigns select_hunk<CR>", { buffer = bufnr, desc = "Select Hunk" })
end

function M.config()
  require("gitsigns").setup({
    signs = M.signs_config,
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with :Gitsigns toggle_current_line_blame
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 1000,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    max_file_length = 40000,
    preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    on_attach = M.on_attach,
  })
end

-- Plugin spec for lazy.nvim
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = M.config,
  _module = M,
}
