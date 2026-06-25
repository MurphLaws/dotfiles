---
phase: 02-tunnelvision-plugin
plan: 01
subsystem: nvim-plugins
tags: [tunnelvision, lazy-load, keybinding, opt-in]
dependencies:
  requires: []
  provides:
    - tunnelvision.nvim lazy.nvim spec with <leader>tv toggle
  affects:
    - nvim plugin initialization (lazy auto-discovery)
tech_stack:
  added:
    - leolaurindo/tunnelvision.nvim (plugin source)
  patterns:
    - lazy.nvim spec with keys lazy-load
    - keybinding via keys table (matches snacks/leap)
key_files:
  created:
    - nvim/.config/nvim/lua/illico/plugins/tunnelvision.lua
  modified: []
decisions:
  - "Toggle API: Use documented :TunnelVision toggle command (robust, avoids Lua API ambiguity)"
  - "Keybinding: <leader>tv (verified free in phase context; user explicit choice)"
  - "Lazy-load strategy: keys = {...} so plugin only loads on <leader>tv press (opt-in, non-intrusive)"
  - "setup() call: opts = {} passes default options (no mode/scope/source override)"
metrics:
  duration: 5min
  completed: 2026-06-25T22:35:00Z
  tasks_completed: 1/1
  files_created: 1
  lines_of_code: 13
---

# Phase 02 Plan 01: Tunnelvision Plugin - Summary

Configure `leolaurindo/tunnelvision.nvim` plugin for Neovim with a lazy-loaded <leader>tv toggle keybinding.

## Objective Achieved

Install and configure tunnelvision.nvim in lazy.nvim with a single toggle keybinding (<leader>tv) that does not auto-load or interfere with editor startup, achieving opt-in activation.

## Completed Tasks

| Task | Name                                         | Commit | Files Created |
|------|----------------------------------------------|--------|---------------|
| 1    | Create tunnelvision.nvim plugin spec        | 6255c4e | tunnelvision.lua |

## Implementation Details

### File Created: `nvim/.config/nvim/lua/illico/plugins/tunnelvision.lua`

**Structure:**
```lua
return {
  {
    "leolaurindo/tunnelvision.nvim",
    opts = {},
    keys = {
      {
        "<leader>tv",
        "<cmd>TunnelVision toggle<CR>",
        desc = "TunnelVision toggle",
      },
    },
  },
}
```

**Key Components:**
- **Plugin string:** `"leolaurindo/tunnelvision.nvim"` (exact, verified)
- **opts:** Empty table `{}` triggers `setup()` with documented defaults
- **keys:** Single keybinding lazy-loading the plugin on `<leader>tv` press
- **Toggle action:** `:TunnelVision toggle` command (documented in plugin README; robust)
- **which-key desc:** `"TunnelVision toggle"` for UI display

**Lazy-load Behavior:**
- Plugin is NOT loaded on nvim startup
- Plugin loads ONLY when `<leader>tv` is pressed
- Ensures zero editor startup impact
- Non-intrusive; existing plugins/keybindings unaffected

**API Verification:**
- Verified `:TunnelVision toggle` command in plugin README (leolaurindo/tunnelvision.nvim official docs)
- Alternative Lua API `require("tunnelvision").is_active()` + `.on()/.off()` available if command unavailable at runtime
- Documentation confirms Neovim >= 0.9 (local config: 0.11 ✓)

## Verification Results

```
✓ File exists: nvim/.config/nvim/lua/illico/plugins/tunnelvision.lua
✓ Plugin string correct: "leolaurindo/tunnelvision.nvim"
✓ Keybinding present: <leader>tv
✓ Toggle desc present: "TunnelVision toggle"
✓ opts = {} present (enables setup() call)
✓ Lua syntax valid (luac -p: no parse errors)
```

## Pattern Adherence

- **Matches leap.lua structure:** Plugin spec with config patterns
- **Matches snacks.lua keys pattern:** keys = {...} lazy-load syntax
- **Indentation:** TAB-indented (matches plugin directory convention)
- **Comments:** Minimal; config is self-documenting (standard for plugin specs)
- **Return structure:** Single-plugin spec table per lazy.nvim convention

## Deviations from Plan

None — plan executed exactly as specified.

## Known Issues

None — plugin source not yet fetched by lazy.nvim (will occur on first nvim startup). Lua API (`.is_active()` + toggle wrapper) is available as fallback if `:TunnelVision toggle` command is not registered at runtime, but documented command is expected to work.

## Next Steps

1. First nvim startup will trigger lazy.nvim to fetch `leolaurindo/tunnelvision.nvim` from GitHub
2. User can press `<leader>tv` to toggle TunnelVision mode on/off
3. which-key will display "TunnelVision toggle" when browsing `<leader>` keybindings
4. No further config needed; plugin is ready for use

---

**Verified by:** Lua syntax check (luac), file existence, pattern matching
**Date:** 2026-06-25
**Commit:** 6255c4e (feat(02-01): configure tunnelvision.nvim plugin...)
