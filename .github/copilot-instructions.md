# Copilot Instructions

## Build, Test, and Lint Commands

- `make test` — Run full test suite (busted)
- `make lint` — Run luacheck linter
- `make test-coverage` — Run tests + generate luacov.report.out
- `make clean` — Remove luacov.stats.out / luacov.report.out
- `make install-deps` — Install busted, luacov, luacheck via luarocks --local

**Run a single spec file:**
```bash
LUA_PATH="./lua/?.lua;./lua/?/init.lua;./spec/?.lua;./spec/?/init.lua;$LUA_PATH" \
  ~/.luarocks/bin/busted spec/core/keymaps_spec.lua
```

Dependencies are installed locally via luarocks (`~/.luarocks/bin/`). The `LUA_PATH` must be set as shown; the Makefile handles this automatically.

## High-Level Architecture

- `init.lua` — Entry point: bootstraps lazy.nvim, loads core.* then plugins.*
- `lua/core/` — Editor options, keymaps, autocmds (no plugin dependencies)
- `lua/plugins/` — One file per plugin, each returns a lazy.nvim spec table
- `spec/` — Mirrors lua/: spec/core/ and spec/plugins/ hold busted tests
- `spec/helpers/vim_mock.lua` — Fake vim global; injected as _G.vim for all tests
- `spec/spec_helper.lua` — Calls vim_mock.setup() and exposes reset_vim_mock()

Plugins with tests (spec/plugins/): `colorscheme`, `lsp`, `nvimtree`, `colorizer`, `copilot`, `gitsigns`.
Plugins without tests (lazy.nvim `keys`/`opts`-only pattern): `telescope`, `treesitter`, `cmp`, `noice`, `notify`, `mason`, `which-keys`, `wrapped`. The `avante` and `agentic` plugins are `enabled = false`.

## Key Conventions

- **Leader key** is `,`.
- Plugins needing tests use the module pattern:
  ```lua
  local M = {}
  M.some_config = { ... }
  function M.config()
    require("plugin").setup(M.some_config)
  end
  return {
    "author/plugin",
    config = M.config,
    _module = M, -- exposed for tests
  }
  ```
- Specs access config tables via `._module` for direct assertions.
- Each spec begins with `require("spec_helper")` and calls `reset_vim_mock()` in a `before_each`.
- Assertions against Neovim behavior (keymaps, autocmds, options, signs) go through `vim_mock._state.*`.
- `vim.keymap._get_keymap(mode, lhs)` is a test-only helper for keymap lookup.
- The mock's `vim.fn.executable` whitelist controls which LSP servers appear "installed".
- `luacheck` excludes `spec/helpers/vim_mock.lua` (it intentionally sets globals).
- LSP servers not in the `allowed_servers` whitelist in `lua/plugins/lsp.lua` are skipped even if Mason installs them. Servers in `denied_servers` (e.g. `ruff`, `pylint`, `flake8`) are always blocked.
- `ruff` is only activated when `[tool.ruff]` exists in `pyproject.toml` or `ruff.toml` is present (logic in `autocmds.lua`).
- `vim.lsp.buf.rename` is overridden in `autocmds.lua` to always delegate exclusively to `pyright`. Other LSP clients have `renameProvider` disabled on attach.
- Auto-import on save (`source.organizeImports`) runs for `*.ts`, `*.tsx`, `*.js`, `*.jsx`, `*.py`, `*.go`, `*.rs`, `*.scala` via `BufWritePre`.
- Config hot-reload: writing any `init.lua`, `lua/core/*.lua`, or `lua/plugins/*.lua` clears `package.loaded` entries and re-requires the changed module automatically.
- LSP is restarted (excluding `copilot`) whenever project config files change (`pyproject.toml`, `tsconfig.json`, `go.mod`, etc.).
