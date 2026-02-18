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

  -- Disable rename for non-pyright LSP clients to avoid duplicate rename dialogs
  autocmd("LspAttach", {
    group = general,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        if client.name ~= "pyright" then
          client.server_capabilities.renameProvider = false
          client.server_capabilities.codeActionProvider = false
        end
      end
    end,
    desc = "Disable rename for non-pyright LSP clients",
  })
  
  -- Override vim.lsp.buf.rename to only use pyright
  vim.lsp.buf.rename = function(...)
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_active_clients({ buffer = bufnr })
    
    -- Find pyright client
    local pyright_client = nil
    for _, client in ipairs(clients) do
      if client.name == "pyright" then
        pyright_client = client
        break
      end
    end
    
    if not pyright_client then
      vim.notify("Pyright not available for rename", vim.log.levels.WARN)
      return
    end
    
    -- Request rename from pyright only
    local params = vim.lsp.util.make_position_params(0, pyright_client.offset_encoding)
    local new_name = vim.fn.input("New name: ")
    if new_name == "" then
      return
    end
    params.newName = new_name
    
    pyright_client.request("textDocument/rename", params, function(err, result)
      if err then
        vim.notify("Rename failed: " .. err.message, vim.log.levels.ERROR)
        return
      end
      if result then
        vim.lsp.util.apply_workspace_edit(result, pyright_client.offset_encoding)
        vim.notify("Renamed successfully", vim.log.levels.INFO)
      end
    end)
  end

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
  
  -- Auto-reload Neovim config when config files change
  local nvim_config_group = augroup("NvimConfigReload", { clear = true })
  
  autocmd("BufWritePost", {
    group = nvim_config_group,
    pattern = { "*init.lua", "*/lua/core/*.lua", "*/lua/plugins/*.lua" },
    callback = function(event)
      vim.defer_fn(function()
        local filename = vim.fn.fnamemodify(event.file, ":t")
        vim.notify("Config reload triggered for: " .. filename, vim.log.levels.WARN)
        
        -- Clear require cache for lua modules
        for module_name, _ in pairs(package.loaded) do
          if module_name:match("^core%.") or module_name:match("^plugins%.") then
            package.loaded[module_name] = nil
          end
        end
        
        -- Reload the modified file
        local relative_path = event.file:gsub(vim.fn.stdpath("config") .. "/", ""):gsub("%.lua$", ""):gsub("/", ".")
        if relative_path:match("^init$") then
          pcall(function()
            require("core.options")
            require("core.keymaps")
            require("core.autocmds")
          end)
        elseif relative_path:match("^core%.") then
          pcall(require, relative_path)
        elseif relative_path:match("^plugins%.") then
          pcall(require, relative_path)
        end
        
        vim.notify(filename .. " reloaded!", vim.log.levels.INFO)
      end, 100)
    end,
    desc = "Auto-reload Neovim config files",
  })
  
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

  -- Restart LSP when project files change (new, deleted, modified)
  autocmd({ "BufWritePost", "BufDelete", "BufNewFile" }, {
    group = lsp_refresh_group,
    callback = function(event)
      local filename = vim.fn.fnamemodify(event.file, ":t")
      local filepath = event.file
      
      -- Get file extension
      local ext = vim.fn.fnamemodify(filepath, ":e")
      
      -- List of project-critical filetypes/patterns that should trigger LSP restart
      local trigger_patterns = {
        -- Python
        "py", "toml", "txt",
        -- TypeScript/JavaScript
        "ts", "tsx", "js", "jsx", "json",
        -- Go
        "go", "mod", "sum",
        -- Rust
        "rs", "toml", "lock",
        -- Scala
        "scala", "sbt", "sc",
        -- Lua
        "lua",
        -- Config files
        "yaml", "yml", "env", "cfg", "ini", "conf"
      }
      
      -- Check if this file should trigger LSP restart
      local should_restart = false
      for _, pattern in ipairs(trigger_patterns) do
        if ext == pattern then
          should_restart = true
          break
        end
      end
      
      -- Also restart if file is in certain directories
      if filepath:match("src/") or filepath:match("lib/") or filepath:match("tests/") or filepath:match("spec/") then
        should_restart = true
      end
      
      if should_restart and event.event ~= "BufDelete" then
        vim.defer_fn(function()
          vim.notify("File change detected: " .. filename .. ". Restarting LSP...", vim.log.levels.DEBUG)
          vim.cmd("LspRestart")
        end, 500)
      end
    end,
    desc = "Restart LSP when project files change",
  })
end

-- Auto-run setup when loaded
M.setup()

return M
