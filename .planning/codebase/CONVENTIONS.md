# Coding Conventions

**Analysis Date:** 2026-06-25

## Naming Patterns

**Files:**
- Lua files use lowercase with hyphens: `options.lua`, `keymaps.lua`, `mini-icons.lua`
- Config files and directories follow XDG conventions: `.config/nvim/`, `.config/ghostty/`, `.tmux/`
- Plugin specs use descriptive lowercase names: `formatting.lua`, `codecompanion.lua`, `real-icons.lua`

**Functions:**
- Snake_case for local functions: `update_q_for_empty_buffer()`, `critic_apply()`
- Keymaps use descriptive camelCase in descriptions: `"move down in buffer with cursor centered"`
- Module functions follow uppercase for module constants: `FocusGained`, `BufEnter`

**Variables:**
- Local variables use snake_case: `lint_augroup`, `float_bg`, `editor_transparent`
- Global Vim settings use `vim.opt.*` or `vim.g.*` for proper scoping
- Configuration tables use uppercase for public values: `@thm_bg`, `@thm_red` (tmux theme colors)

**Types:**
- Lua tables for options use CamelCase keys mirroring Neovim API: `styles`, `formatters`, `linters_by_ft`
- Plugin spec tables follow lazy.nvim convention: `event`, `dependencies`, `config`, `keys`, `opts`

## Code Style

**Formatting:**
- Tool: `stylua` (Lua formatter)
- Indentation: 4 spaces (set in `conform.nvim`)
- Line length: No hard limit enforced, but code tends to stay under 100 chars for readability

**Linting:**
- Tool: `luacheck` for Lua files (configured in `lua_ls` LSP)
- No global linting config file; validation done per-language in Neovim via `nvim-lint`
- Biome for JavaScript/TypeScript, Prettier for markdown/JSON/YAML

**Indentation Convention:**
```lua
-- 4-space indentation throughout
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
```

## Import Organization

**Order:**
1. Standard library imports (`require("vim")`, core modules)
2. Plugin/external requires (`require("lazy")`, `require("snacks")`)
3. Local module requires (`require("illico.core")`, `require("illico.lazy")`)
4. Local functions and setup

**Path Aliases:**
- No explicit path aliases; uses relative Lua module paths under `lua/illico/`
- Plugins organized by category: `illico/plugins/`, `illico/plugins/lsp/`, `illico/core/`
- Lazy.nvim auto-discovers specs: `{ import = "illico.plugins" }` loads all files under that directory

**Example from `init.lua`:**
```lua
vim.g.mapleader = " "
require("illico.core")
require("illico.lazy")
vim.notify = require("snacks").notifier.notify
```

## Error Handling

**Patterns:**
- Safe requires with `pcall()` for optional plugins:
  ```lua
  local ok_quarto, quarto = pcall(require, "quarto")
  if not ok_quarto then
    return
  end
  ```
- Autocmd safety: Check `vim.bo.buftype` and `vim.bo.modifiable` before operating on buffers (avoid E21 on special buffers):
  ```lua
  if vim.bo.modifiable and vim.bo.buftype == "" then
    trailspace.trim()
  end
  ```
- Silent keymap execution with `{ silent = true }` to prevent command echoing
- Silent LSP diagnostics updates with `update_in_insert = true` to avoid lag

## Logging

**Framework:** `vim.notify()` (configured via Snacks notifier)

**Patterns:**
- Use `vim.notify()` for UI messages (not `print()` which prints to stdout)
- File path logging: `print("File path copied to clipboard: " .. filePath)` for status messages
- Comments inline document intent; no structured logging framework used (personal config)

## Comments

**When to Comment:**
- Section separators using dashes: `-- ===== System clipboard =====` (visual organization)
- Intent explanations for non-obvious code: "Auto-reload files changed outside nvim"
- Disable explanations: "Disable netrw (we use mini.files for file exploration)"
- Spanish comments mixed with English — see "Language" below

**Comment Style:**
- Inline single-line comments use `--` with single space: `-- Some comment`
- Block comments use visual separators:
  ```lua
  -- ── CriticMarkup ───────────────────────────────────────────────────────────
  ```
- VSCode-style headings: `-- ===== Basics =====`, `-- ─────────────────────────`, `-- ── Section ──`

**Language:**
- Comments written in Spanish (neutral, latinoamericano):
  - Example: `-- Silencia los warnings de :checkhealth por neovim npm / perl / ruby gem.`
  - Example: `-- Resalta la línea donde está el cursor`
- English used in keymap descriptions (`:desc` fields)

**JSDoc/TSDoc:**
- Not used in this Lua-based config; Lua lacks standard documentation convention
- Function intent documented inline where needed

## Function Design

**Size:** 
- Most functions stay under 30 lines
- Larger plugin configs break logic into setup blocks:
  ```lua
  config = function()
    local conform = require("conform")
    conform.setup({...})
    -- Keymaps and further setup
  end
  ```

**Parameters:**
- Functions use descriptive parameter names: `function(pre, post)` for string wrapping
- Callbacks receive standard Neovim names: `callback = function()`, `pattern = "*"`
- No destructuring of complex tables; extract fields inline if needed

**Return Values:**
- Plugin specs return a table (lazy.nvim convention)
- Helper functions may return functions (closures for keymaps): `return function() ... end`
- Most functions operate on side effects (setting options, registering keymaps)

## Module Design

**Exports:**
- Each plugin file returns a single lazy.nvim spec table:
  ```lua
  return {
    "plugin/name",
    event = {...},
    config = function() ... end,
  }
  ```
- Core modules (`illico/core/*`) use `require()` pattern; no explicit exports

**Barrel Files:**
- `lua/illico/core/init.lua` imports all core submodules: `require("illico.core.options")`, etc.
- `lua/illico/plugins/init.lua` — not present; lazy.nvim imports via `{ import = "illico.plugins" }`
- Plugin specs are flat (no nesting); Lazy discovers them automatically

**File Organization:**
```
nvim/.config/nvim/
├── init.lua                    # Entry point: set mapleader, require core + lazy
├── lua/illico/
│   ├── core/
│   │   ├── init.lua           # Barrel: require all core modules
│   │   ├── options.lua        # Vim options (tabstop, clipboard, etc.)
│   │   ├── keymaps.lua        # Global keymaps
│   │   ├── python.lua         # Python provider config
│   │   ├── godot.lua          # Godot-specific setup
│   │   └── quarto_split.lua   # Quarto integration
│   ├── plugins/
│   │   ├── *.lua              # Individual plugin specs (no init.lua)
│   │   └── lsp/
│   │       ├── mason.lua      # LSP tool installer
│   │       └── lspconfig.lua  # LSP server configuration
│   ├── lazy.lua               # Lazy.nvim bootstrap and setup
│   └── narrow.lua             # Markdown section narrowing utility
├── ftplugin/
│   └── markdown.lua           # CriticMarkup + Quarto runner
├── colors/
│   └── superset.lua           # Custom Catppuccin Mocha highlights
└── local-plugins/             # Manually maintained plugins
```

## Plugin Spec Convention

All plugins follow lazy.nvim specification:

```lua
return {
  "github/plugin-name",
  event = {"BufReadPre", "BufNewFile"},  -- Load on file events or "VeryLazy"
  dependencies = {"other/plugin"},        -- Implicit loading of dependencies
  config = function()                     # Setup function (called when loaded)
    -- Configuration and keymaps here
  end,
  keys = {                                -- Define keymaps that lazy-load the plugin
    { "<leader>xx", function() ... end, desc = "..." }
  },
  opts = { ... }                          -- Options passed to module setup
}
```

## Theming and Color Conventions

**Color Scheme:**
- Primary: Catppuccin Mocha (`catppuccin-mocha`)
- Transparent background enabled: `transparent_background = true` (lets terminal/tmux show through)
- Configured in `lua/illico/plugins/colorscheme.lua`

**Color Palette (from Catppuccin Mocha):**
```lua
-- Base colors (from tmux.conf)
@thm_bg = "#1e1e2e"           -- Dark background
@thm_fg = "#cdd6f4"           -- Light foreground
@thm_overlay_0 = "#6c7086"    -- Medium gray
@thm_white = "#bac2de"        -- Light gray

-- Accents
@thm_red = "#f38ba8"          -- For errors, deletions
@thm_green = "#a6e3a1"        -- For additions, success
@thm_yellow = "#f9e2af"       -- For warnings, attention
@thm_blue = "#89b4fa"         -- For info, ui
@thm_magenta = "#cba6f7"      -- For special
@thm_cyan = "#94e2d5"         -- For changes, alternatives
```

**Transparency Strategy:**
- Editor panes (`Normal`, `NormalNC`, `SignColumn`): 100% transparent (show desktop/terminal)
- Menus/Floats (`NormalFloat`, `Pmenu`, picker windows): Panel background `#181825` (Catppuccin mantle, opaque)
- Borders: Invisible (set to panel color to avoid visual clutter)

**CriticMarkup Highlighting (Markdown):**
```lua
CriticComment   -- {>>comment<<}        Amber bg + italic
CriticHighlight -- {==highlight==}     Amber bg + bold
CriticAdd       -- {++addition++}       Green bg
CriticDel       -- {--deletion--}       Red + strikethrough
CriticSub       -- {~~old~>new~~}      Cyan bg
```

## Commit Message Conventions

**Language:** Spanish (neutral, latinoamericano)

**Format:** `<scope>: <description>`

**Examples:**
- `nvim: menus sin borde y con fondo de panel opaco (todos los plugins)`
- `nvim: desactiva integracion mini_files de real-icons (congelaba <leader>e)`
- `nvim: instala real-icons.nvim (pack material) + picker unificado con transparencia`
- `nvim: elimina foldtext.lua (plugin spec ya no usado)`
- `nvim: narrow en pestaña nueva (pantalla completa) + tecla 'e' en aerial restaurada`

**Scope:** Tool name in lowercase (e.g., `nvim`, `tmux`, `ghostty`, `claude`)

**Style:**
- Lowercase throughout (except proper nouns and acronyms like `LSP`, `PDF`)
- Lowercase after colons: `nvim: menus...` not `nvim: Menus...`
- Detail rationale in parentheses for clarity: `(congelaba <leader>e)`
- Use imperative mood when applicable: `instala`, `desactiva`, `elimina`, `arranca`

---

*Convention analysis: 2026-06-25*
