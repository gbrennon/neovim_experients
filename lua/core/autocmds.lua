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

  -- Check if file changed outside of vim and auto-reload
  autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter", "CursorHold" }, {
    group = general,
    callback = function()
      -- Check for file changes and reload buffer if changed
      vim.cmd("checktime")
      
      -- Refresh nvim-tree if it's loaded and open
      local nvim_tree_ok, api = pcall(require, "nvim-tree.api")
      if nvim_tree_ok then
        local view = require("nvim-tree.view")
        if view.is_visible() then
          api.tree.reload()
        end
      end
    end,
    desc = "Auto-reload files and refresh nvim-tree on focus/cursor hold",
  })

  -- LSP refresh and auto-import group
  local lsp_group = augroup("LspAutoImport", { clear = true })

  -- Auto-import / organize imports on save
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

  -- LSP auto-refresh group
  local lsp_refresh_group = augroup("LspAutoRefresh", { clear = true })
  
  -- Restart LSP when config files change
  autocmd({ "BufWritePost", "FileChangedShellPost" }, {
    group = lsp_refresh_group,
    pattern = { 
      "pyproject.toml", "requirements.txt", "setup.py", "setup.cfg", "Pipfile", "pyrightconfig.json",
      "tsconfig.json", "jsconfig.json", "package.json", "package-lock.json", 
      "go.mod", "go.work", "go.sum", "Cargo.toml", "Cargo.lock", 
      "build.sbt", "build.sc", ".scala-build",
      ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml"
    },
    callback = function(event)
      vim.defer_fn(function()
        local filename = vim.fn.fnamemodify(event.file, ":t")
        vim.notify("Config file " .. filename .. " changed. Restarting LSP...", vim.log.levels.INFO)
        
        -- Use the reliable vim.lsp restart approach
        local clients = vim.lsp.get_clients()
        for _, client in ipairs(clients) do
          local buffers = vim.lsp.get_buffers_by_client_id(client.id)
          vim.lsp.stop_client(client.id, true)
          
          -- Restart after a brief delay
          vim.defer_fn(function()
            for _, buf in ipairs(buffers) do
              if vim.api.nvim_buf_is_valid(buf) then
                local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
                -- Trigger LSP attach by simulating filetype event
                vim.api.nvim_exec_autocmds("FileType", {
                  buffer = buf,
                  data = { filetype = filetype }
                })
              end
            end
          end, 1500)
        end
      end, 500)
    end,
    desc = "Restart LSP when config files change",
  })

  -- Alternative: Watch for external config changes using vim's file watching
  autocmd({ "FocusGained", "BufEnter" }, {
    group = lsp_refresh_group,
    callback = function()
      -- Check if any config files changed and restart if needed
      local config_files = {
        "pyproject.toml", "requirements.txt", "package.json", "tsconfig.json", 
        "go.mod", "Cargo.toml", "build.sbt", ".luarc.json"
      }
      
      for _, config_file in ipairs(config_files) do
        local filepath = vim.fn.expand(config_file)
        if vim.fn.filereadable(filepath) == 1 then
          -- Check if file was modified since last check
          local modtime = vim.fn.getftime(filepath)
          local last_modtime = vim.g["lsp_config_modtime_" .. config_file:gsub("%.", "_")]
          
          if last_modtime and modtime > last_modtime then
            vim.g["lsp_config_modtime_" .. config_file:gsub("%.", "_")] = modtime
            vim.notify("Detected " .. config_file .. " changes. Restarting LSP...", vim.log.levels.INFO)
            vim.cmd("LspRestart")
            break -- Only restart once per focus
          elseif not last_modtime then
            -- Initialize the timestamp
            vim.g["lsp_config_modtime_" .. config_file:gsub("%.", "_")] = modtime
          end
        end
      end
    end,
    desc = "Check for config file changes on focus and restart LSP",
  })
end

-- Auto-run setup when loaded
M.setup()

return M
