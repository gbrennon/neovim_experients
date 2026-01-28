# Neovim Configuration

A modular Neovim configuration built with Lua and lazy.nvim plugin manager, targeting Neovim 0.11+.

## Features

- **Colorscheme**: [badwolf](https://github.com/sjl/badwolf) dark theme
- **File Explorer**: [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) with custom keymaps
- **LSP**: Native LSP support for Lua, Python, Go, Rust, Scala, TypeScript/JavaScript, JSON, YAML, HTML, CSS
- **Auto-import**: Automatically organizes imports on save for Go, TypeScript, JavaScript, and Python
- **Copilot**: GitHub Copilot integration with auto-trigger suggestions
- **Colorizer**: Inline color previews for CSS/hex values

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
│       └── copilot.lua         # GitHub Copilot
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
│       └── copilot_spec.lua
└── Makefile
```

## Key Mappings

Leader key: `,`

| Key | Mode | Description |
|-----|------|-------------|
| `,w` | n | Save |
| `,q` | n | Quit |
| `,e` | n | Toggle file explorer |
| `F3` | n | Toggle file explorer |
| `,fe` | n | Focus file explorer |
| `,ca` | n | Code action (includes auto-import) |
| `,f` | n | Format buffer |
| `,rn` | n | Rename symbol |
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gi` | n | Go to implementation |
| `gr` | n | Find references |
| `K` | n | Hover documentation |
| `Tab` | n | Next buffer |
| `S-Tab` | n | Previous buffer |
| `jk` | i | Exit insert mode |

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

Current coverage: **99.30%** (263 tests)

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
