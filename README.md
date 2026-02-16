# Neovim Configuration

A modular Neovim configuration built with Lua and lazy.nvim plugin manager, targeting Neovim 0.11+.

## Features

- **Colorscheme**: [badwolf](https://github.com/sjl/badwolf) dark theme
- **File Explorer**: [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) with custom keymaps
- **LSP**: Native LSP support for Lua, Python, Go, Rust, Scala, TypeScript/JavaScript, JSON, YAML, HTML, CSS
- **Auto-import**: Automatically organizes imports on save for Go, TypeScript, JavaScript, and Python
- **Copilot**: GitHub Copilot integration with auto-trigger suggestions
- **Colorizer**: Inline color previews for CSS/hex values
- **Git Integration**: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for visual git diff indicators

## Structure

```
.
├── init.lua                    # Entry point, bootstraps lazy.nvim
├── lua/
│   ├── core/
│   │   ├── options.lua         # Editor options (tabs, search, appearance, etc.)
│   │   ├── keymaps.lua         # Key mappings (leader=,)
│   │   └── autocmds.lua        # Autocommands (yank highlight, trailing whitespace, auto-import)
│   └── plugins/
│       ├── init.lua            # Plugin loader
│       ├── colorscheme.lua     # badwolf theme
│       ├── lsp.lua             # LSP server configurations
│       ├── nvimtree.lua        # File explorer
│       ├── colorizer.lua       # Color previews
│       ├── copilot.lua         # GitHub Copilot
│       └── gitsigns.lua        # Git diff indicators
├── spec/                       # Test suite (busted)
│   ├── spec_helper.lua
│   ├── helpers/
│   │   └── vim_mock.lua        # Vim API mock for unit testing
│   ├── core/
│   │   ├── options_spec.lua
│   │   ├── keymaps_spec.lua
│   │   └── autocmds_spec.lua
│   └── plugins/
│       ├── colorscheme_spec.lua
│       ├── lsp_spec.lua
│       ├── nvimtree_spec.lua
│       ├── colorizer_spec.lua
│       ├── copilot_spec.lua
│       └── gitsigns_spec.lua
└── Makefile
```

## Key Mappings

Leader key: `,`

### General

| Key | Mode | Description |
|-----|------|-------------|
| `,w` | n | Save |
| `,q` | n | Quit |
| `,e` | n | Toggle file explorer |
| `F3` | n | Toggle file explorer |
| `,fe` | n | Focus file explorer |
| `Tab` | n | Next buffer |
| `S-Tab` | n | Previous buffer |
| `jk` | i | Exit insert mode |

### LSP

| Key | Mode | Description |
|-----|------|-------------|
| `,ca` | n | Code action (includes auto-import) |
| `,f` | n | Format buffer |
| `,rn` | n | Rename symbol |
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gi` | n | Go to implementation |
| `gr` | n | Find references |
| `K` | n | Hover documentation |
| `[d` | n | Previous diagnostic |
| `]d` | n | Next diagnostic |
| `,dl` | n | Show diagnostic |

### Git (Gitsigns)

| Key | Mode | Description |
|-----|------|-------------|
| `]c` | n | Next git hunk |
| `[c` | n | Previous git hunk |
| `,hs` | n/v | Stage hunk |
| `,hr` | n/v | Reset hunk |
| `,hS` | n | Stage buffer |
| `,hu` | n | Undo stage hunk |
| `,hR` | n | Reset buffer |
| `,hp` | n | Preview hunk |
| `,hb` | n | Blame line |
| `,hd` | n | Diff this |
| `,hD` | n | Diff this (cached) |
| `ih` | o/x | Select hunk (text object) |

## LSP Servers

| Server | Languages |
|--------|-----------|
| lua_ls | Lua |
| pyright | Python |
| gopls | Go |
| rust_analyzer | Rust |
| metals | Scala, sbt, Java |
| ts_ls | TypeScript, JavaScript |
| jsonls | JSON |
| yamlls | YAML |
| html | HTML |
| cssls | CSS, SCSS, Less |

## Auto-Import

Imports are automatically organized on save for:
- **Go** (via `gopls` `source.organizeImports`)
- **TypeScript/JavaScript** (via `ts_ls` `source.organizeImports`)
- **Python** (via `pyright` `source.organizeImports`)

You can also manually trigger import via `,ca` (code action).

## Git Integration

### Visual Indicators

Gitsigns provides visual indicators in the sign column:
- **Green bars** (`│`) - Added lines
- **Blue bars** (`│`) - Modified lines
- **Red indicators** (`_`, `‾`, `~`) - Deleted lines
- **Dotted bars** (`┆`) - Untracked files

### Features

- **Hunk Navigation**: Jump between changes with `]c` and `[c`
- **Hunk Preview**: View diff inline with `,hp`
- **Git Blame**: See commit info with `,hb`
- **Staging**: Stage individual hunks or entire buffer
- **Diff View**: Compare with HEAD or index

### Toggling Blame

Current line blame is disabled by default. Toggle it with:
```vim
:Gitsigns toggle_current_line_blame
```

## Development

### Prerequisites

```bash
luarocks install busted --local
luarocks install luacov --local
luarocks install luacheck --local
```

### Running Tests

```bash
make test             # Run tests
make test-coverage    # Run tests with coverage report
make lint             # Run luacheck linter
make clean            # Remove generated coverage files
```

### Test Coverage

Current coverage: **99.30%** (263+ tests)

| File | Coverage |
|------|----------|
| core/autocmds.lua | 100.00% |
| core/keymaps.lua | 97.67% |
| core/options.lua | 100.00% |
| plugins/colorizer.lua | 100.00% |
| plugins/colorscheme.lua | 100.00% |
| plugins/copilot.lua | 100.00% |
| plugins/lsp.lua | 99.29% |
| plugins/nvimtree.lua | 100.00% |
| plugins/gitsigns.lua | 100.00% |

## Architecture

This configuration follows SOLID principles:

- **Single Responsibility**: Each module handles one concern (LSP, keymaps, etc.)
- **Open/Closed**: Plugins are configured via tables, easily extendable
- **Dependency Inversion**: Core modules are independent of plugin implementations
- **Testability**: 99%+ test coverage with mocked Vim API

### Module Structure

Each plugin follows a consistent pattern:

```lua
local M = {}

-- Configuration tables (easily testable)
M.config_table = { ... }

-- Setup function
function M.config()
  require("plugin").setup(M.config_table)
end

-- Lazy.nvim spec
return {
  "author/plugin",
  config = M.config,
  _module = M,  -- Exposed for testing
}
```

This structure enables:
- **Unit Testing**: All configuration is in tables, not inline
- **Reusability**: Functions can be called independently
- **Maintainability**: Clear separation between config and plugin loading
