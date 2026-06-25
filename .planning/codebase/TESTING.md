# Testing Patterns

**Analysis Date:** 2026-06-25

## Overview

This is a personal **dotfiles repository** (configuration files for Neovim, tmux, Ghostty, etc.). There is **no formal test suite**. Instead, changes are validated through:
1. Manual reloading of configuration
2. Neovim `:checkhealth` diagnostic
3. Linting and formatting checks (integrated into Neovim)
4. Visual verification in the editor

## Test Framework

**Runner:**
- None (no test suite)
- Validation: Manual + built-in Neovim diagnostics

**Linters (Integrated into Neovim):**
- Framework: `nvim-lint` (on-demand linting during editing)
- Config: `lua/illico/plugins/nvim-lint.lua`

**Formatters:**
- Framework: `conform.nvim` (on-save formatting)
- Config: `lua/illico/plugins/formatting.lua`

**Run Commands:**
```bash
# Manual validation
nvim +checkhealth      # Run Neovim diagnostics (no lsp, no provider issues)
nvim <file>            # Open file and observe linting/formatting

# Formatting check (from within Neovim)
<leader>mp             # Format current file or visual selection

# Linting check (from within Neovim)
<leader>l              # Trigger linter for current file
```

## Change Validation Workflow

### 1. Reload Configuration in Neovim

**Pattern:** After editing a config file, reload Neovim to apply changes.

**Methods:**
- Restart Neovim entirely: `:qa!` then `nvim <file>`
- Source a Lua file: `:luafile <path>` (for `lua/illico/core/options.lua`, etc.)
- Reload plugins: `:Lazy reload <plugin-name>` (via Lazy.nvim)

**Autocmd Reload on Focus:**
```lua
-- From lua/illico/core/options.lua
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")  -- Reload files changed outside nvim
    end
  end,
})
```

External changes (e.g., edits to `init.lua` while Neovim is running) trigger automatic reload via `:checktime`.

### 2. Checkhealth Validation

**Purpose:** Verify Neovim configuration is healthy (no missing LSP servers, no dangling providers).

**Command:**
```bash
nvim +checkhealth +quit
```

**What It Checks:**
- Provider availability (Python, Node, Ruby, Perl) — disabled except Python3
- LSP tools installed (Mason-managed servers like `lua_ls`, `ts_ls`, `html`, `cssls`)
- Plugin health (warnings about deprecated/missing plugins)

**Example Output (Expected):**
```
nvim
  - OK     version 0.11+ (NVIM v0.11.0-dev)
  - OK     tree-sitter executable found: ...
  - OK     unzip found.
  ...
  - OK     node_provider is disabled (intentional)
  - OK     perl_provider is disabled (intentional)
  - OK     ruby_provider is disabled (intentional)
```

### 3. Linting During Editing

**Framework:** `nvim-lint`

**Filetype → Linter Mapping:**
```lua
lint.linters_by_ft = {
  javascript = { "biomejs" },
  typescript = { "biomejs" },
  javascriptreact = { "biomejs" },
  typescriptreact = { "biomejs" },
  svelte = { "biomejs" },
  python = { "pylint" },
  lua = { "luacheck" },
  yaml = { "yamllint" },
  gdscript = { "gdlint" },
}
```

**When Linting Runs:**
- Autocmd trigger: `BufEnter`, `BufWritePost`, `InsertLeave`
- Manual trigger: `<leader>l` (via keymap in `linting.lua`)

**Linter Output:**
- Shown in `:Trouble` quickfix window or Neovim's diagnostic system
- Errors/warnings displayed inline with Catppuccin Mocha colors

### 4. Formatting on Save

**Framework:** `conform.nvim`

**Formatter Configuration:**
```lua
-- lua/illico/plugins/formatting.lua
formatters_by_ft = {
  javascript = { "biome-check" },
  typescript = { "biome-check" },
  lua = { "stylua" },
  markdown = { "prettier", "markdown-toc" },
  -- ... others
}

format_on_save = {
  lsp_fallback = true,
  async = false,
  timeout_ms = 1000,
}
```

**Manual Format:**
```
<leader>mp    # Format file or visual selection
```

**Key Formatters:**
- `stylua`: Lua files (4-space indentation, no line-length limit)
- `biome-check`: JavaScript/TypeScript (Biome linter + formatter)
- `prettier`: Markdown, JSON, YAML (4-space tabs disabled)
- `gdtoolkit`: GDScript (Godot linting + formatting)

## Plugin Configuration Testing

### Lazy.nvim Plugin Specs

Each plugin is defined as a Lua table. Changes are tested by:

1. **Syntax Check:** Lua syntax must be valid (caught on `:luafile` or Neovim startup)
2. **Lazy Spec Validation:** Lazy.nvim validates `event`, `dependencies`, `config` at startup
3. **Runtime Testing:** Boot Neovim and verify plugin loads without errors

**Example Test Flow:**
```lua
-- lua/illico/plugins/snacks.lua
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = { ... },
  }
}
-- Test: nvim +Lazy should show snacks.nvim loaded with no errors
```

### LSP Configuration Testing

**Servers configured in:** `lua/illico/plugins/lsp/mason.lua` and `lua/illico/plugins/lsp/lspconfig.lua`

**Validation Steps:**

1. **Install tools:** `:Mason` command opens UI to install servers
   ```
   ensure_installed = { "lua_ls", "ts_ls", "html", "cssls", ... }
   ```

2. **Check status:** `:Mason` → verify all servers show checkmark (✓)

3. **Test LSP in a file:** Open a supported filetype (e.g., `.lua`, `.ts`, `.py`)
   - Hover over identifiers: `K` should show signature help
   - Request completions: `<C-x><C-o>` or completion menu
   - Check diagnostics: `:Trouble` should show any LSP errors

4. **Checkhealth verification:**
   ```bash
   nvim +checkhealth nvim-lspconfig +quit
   ```

### UI/Theme Testing

**Steps:**
1. Open Neovim: `nvim`
2. Verify Catppuccin Mocha colors load: editor should have dark background, light text
3. Test transparency:
   - Editor area should show desktop/terminal behind (100% transparent)
   - Menu/picker windows should show opaque panel background
   - No visible borders on menus (color set to panel background)
4. Test highlights:
   - Syntax colors appear correct
   - Italics on comments (if font supports)
   - CriticMarkup colors in `.md` files (`:e test.qmd`)

**Files to test:**
- `lua/illico/plugins/colorscheme.lua` — Catppuccin + transparency setup
- `lua/illico/plugins/snacks.lua` — Picker UI styling
- `ftplugin/markdown.lua` — CriticMarkup highlighting

## Manual Verification Checklist

**After Modifying Core Configuration:**

- [ ] Neovim starts without errors: `nvim`
- [ ] No startup slowdown (lazy-loading is working)
- [ ] `:checkhealth` shows all green (or expected yellows/info)
- [ ] Keymaps work: Try `<leader>mp` (format), `<leader>l` (lint)
- [ ] Colors correct: Editor transparent, menus opaque, no visible borders
- [ ] LSP works: Open a `.lua` or `.ts` file, hover over a symbol with `K`

**After Modifying Plugin Specs:**

- [ ] Close Neovim fully and reopen
- [ ] Run `:Lazy reload <plugin-name>` if modifying loaded plugin
- [ ] Check `:Lazy` dashboard for errors (red indicators)
- [ ] Test plugin functionality (e.g., `:Telescope` for telescope.nvim)

**After Modifying Keymaps:**

- [ ] Test each new/modified keymap in the intended mode (`n`, `v`, `i`, etc.)
- [ ] Verify no conflicts with existing bindings
- [ ] Check `:map <leader>xx` to see keymap definition and source file

## File-Specific Validation

**`init.lua`:**
- Simplest to test: just reload with `:luafile %`
- If syntax error, Neovim won't start

**`lua/illico/core/*.lua`:**
- Reload with `:luafile lua/illico/core/options.lua`
- Test specific settings: `:set tabstop?` to verify option was set

**`lua/illico/plugins/*.lua`:**
- Lazy loads on event or demand
- Check `:Lazy show <plugin>` to see load status
- Verify in `:Trouble` if plugin reports diagnostic issues

**`lua/illico/plugins/lsp/*.lua`:**
- Test LSP server: `:LspInfo` shows active servers
- Check log: `:e ~/.local/state/nvim/lsp.log` for server errors

**`ftplugin/markdown.lua`:**
- Test CriticMarkup highlighting: `:e test.qmd`
- Edit file with critic syntax: `{>>comment<<}`, `{==highlight==}`, etc.
- Verify colors appear correct

**`tmux/.tmux.conf`:**
- Reload in tmux: `tmux source ~/.tmux.conf`
- Test pane navigation: `h/j/k/l` to move between panes
- Test colors: Windows/panes should display Catppuccin Mocha theme

**`ghostty/.config/ghostty/config`:**
- Restart Ghostty for changes to take effect
- Verify window opacity, font, and key bindings

## Coverage Gaps and Limitations

**No automated testing for:**
- Plugin interaction (e.g., does snacks.nvim play well with aerial.nvim in all scenarios?)
- Performance regression (no baseline benchmarks)
- Cross-platform compatibility (only tested on macOS)
- Neovim version compatibility (only tested on latest `v0.11+`)

**Mitigations:**
- Manual smoke testing after each edit
- Commit messages document intent and any known issues
- Revert commits quickly if regression detected (git is the safety net)

## Troubleshooting Validation

**If Neovim won't start:**
```bash
nvim --noplugin          # Bypass plugins to isolate config issue
nvim -u NONE             # Use minimal config (debug)
nvim +checkhealth        # Diagnostic output
```

**If a plugin fails to load:**
```bash
nvim +Lazy               # Shows error details in :Lazy dashboard
vim ~/.local/state/nvim/lsp.log  # LSP server logs
```

**If keymaps don't work:**
```vim
:map <leader>xx          # Show keymap definition
:verbose map <leader>xx  # Show which file defined it
```

**If colors are wrong:**
```vim
:colorscheme              # Verify current colorscheme
:highlight Normal         # Check Normal group bg/fg
:echo synID(line('.'),col('.'),-1)  # Inspect highlight group at cursor
```

---

*Testing validation pattern: 2026-06-25*
