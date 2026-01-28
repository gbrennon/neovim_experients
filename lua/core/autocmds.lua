-- Autocommands Configuration

local M = {}

function M.setup()
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd

  -- General settings group
  local general = augroup("General", { clear = true })

  -- Highlight on yank
  autocmd("TextYankPost", {
    group = general,
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
    desc = "Highlight on yank",
  })

  -- Remove trailing whitespace on save
  autocmd("BufWritePre", {
    group = general,
    pattern = "*",
    command = [[%s/\s\+$//e]],
    desc = "Remove trailing whitespace",
  })

  -- Restore cursor position
  autocmd("BufReadPost", {
    group = general,
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lcount = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
    desc = "Restore cursor position",
  })

  -- Close some filetypes with <q>
  autocmd("FileType", {
    group = general,
    pattern = { "help", "lspinfo", "man", "notify", "qf", "checkhealth" },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
    desc = "Close certain filetypes with q",
  })

  -- Auto resize splits when window is resized
  autocmd("VimResized", {
    group = general,
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
    desc = "Auto resize splits",
  })

  -- Check if file changed outside of vim
  autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = general,
    command = "checktime",
    desc = "Check if file changed",
  })

  -- Auto-import / organize imports on save
  local lsp_group = augroup("LspAutoImport", { clear = true })

  autocmd("BufWritePre", {
    group = lsp_group,
    pattern = { "*.go", "*.ts", "*.tsx", "*.js", "*.jsx", "*.py" },
    callback = function()
      local params = vim.lsp.util.make_range_params()
      params.context = { only = { "source.organizeImports" } }
      local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
      for _, res in pairs(result or {}) do
        for _, action in pairs(res.result or {}) do
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
          elseif action.command then
            vim.lsp.buf.execute_command(action.command)
          end
        end
      end
    end,
    desc = "Auto-import and organize imports on save",
  })
end

-- Auto-run setup when loaded
M.setup()

return M
