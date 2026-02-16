# Auto-Refresh Verification Guide

This guide helps you verify that the auto-refresh functionality is working correctly.

## 1. File Content Auto-Refresh

### Test 1: External File Modification
```bash
# 1. Open a file in Neovim
nvim test_file.txt

# 2. In another terminal, modify the file
echo "Content added externally" >> test_file.txt

# 3. Back in Neovim, focus the window (click or Alt+Tab)
# Expected: File should automatically reload and show new content
# You should see a message like "test_file.txt has changed since editing started"
```

### Test 2: CursorHold Trigger
```bash
# 1. Open a file in Neovim
# 2. Modify it externally (as above)
# 3. In Neovim, move cursor and wait 1 second without typing
# Expected: File should reload automatically after cursor hold timeout
```

## 2. Nvim-Tree Auto-Refresh

### Test 1: File System Watcher
```bash
# 1. Open Neovim and toggle nvim-tree (:NvimTreeToggle)
# 2. In another terminal, create/delete files in the project directory
mkdir new_folder
touch new_folder/test.txt
rm some_existing_file.txt

# Expected: nvim-tree should update in real-time (within 50ms)
# You should see new files/folders appear and deleted ones disappear
```

### Test 2: Focus-Based Refresh
```bash
# 1. Open nvim-tree
# 2. Switch to another application and modify files externally
# 3. Switch back to Neovim
# Expected: nvim-tree refreshes when Neovim gains focus
```

## 3. LSP Auto-Refresh

### Test 1: Config File Changes (Automatic Detection)
```bash
# Use the provided test script
./test-lsp-restart.sh

# 1. Open the created Python file
nvim test_lsp.py

# 2. Check LSP is running
:LspInfo

# 3. In another terminal, modify requirements.txt
echo "numpy==1.21.0" >> requirements.txt

# 4. Switch back to Neovim (click window or Alt+Tab)
# Expected: "Detected requirements.txt changes. Restarting LSP..." notification
# LSP should restart automatically
```

### Test 2: Direct File Modification Detection
```bash
# 1. Open a Python file with LSP running
nvim main.py

# 2. Modify package.json, tsconfig.json, go.mod, etc. externally
echo '{"compilerOptions": {"strict": true}}' > tsconfig.json

# 3. Save the file (triggers BufWritePost event)
# Expected: "Config file tsconfig.json changed. Restarting LSP..." notification
```

### Test 3: Diagnostic Refresh
```bash
# 1. Open a file with some syntax errors
nvim test.py

# 2. Fix the errors externally (in another editor)
# 3. Focus back to Neovim (click window or Alt+Tab)
# Expected: Diagnostics should clear automatically, LSP will naturally refresh them
# Note: The diagnostics clear immediately on focus, then LSP repopulates them
```

## 4. Visual Indicators to Watch For

### Success Indicators:
- **File changes**: Buffer updates automatically, no manual `:e` needed
- **nvim-tree**: Real-time file system updates without manual refresh
- **LSP notifications**: "Restarting LSP due to config file changes..." message
- **Diagnostics**: Error/warning signs update automatically

### Debug Commands:
```vim
" Check if autoread is enabled
:set autoread?

" Check updatetime setting
:set updatetime?

" Check LSP status
:LspInfo

" Check nvim-tree status
:NvimTreeRefresh

" Monitor autocmd events (for debugging)
:autocmd FocusGained
:autocmd CursorHold
:autocmd BufWritePost
```

## 5. Common Issues & Troubleshooting

### File not refreshing?
- Check if file has unsaved changes (prevents auto-reload)
- Verify `autoread` is enabled: `:set autoread?`
- Try manual refresh: `:checktime`

### nvim-tree not updating?
- Ensure filesystem watchers are supported on your system
- Check if the file is in an ignored directory
- Manual refresh: `:NvimTreeRefresh`

### LSP not restarting?
- Verify the config file pattern matches (see autocmd patterns)
- Check if LSP was active: `:LspInfo`
- Manual restart: `:LspRestart`

## 6. Performance Notes

- **updatetime**: Set to 1000ms (1 second) for cursor hold events
- **nvim-tree debounce**: 50ms delay prevents excessive refreshes
- **LSP restart delay**: 500ms delay allows file writes to complete
- **Ignored directories**: Common build/dependency folders are ignored for performance