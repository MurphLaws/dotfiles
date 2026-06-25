---
phase: 01-semitransparent-floats
plan: 01
subsystem: nvim/colorscheme
tags: [transparency, floats, blending, ui-consistency]
depends_on: []
provides: [global winblend settings, snacks picker semitransparency]
affects: [NormalFloat, Pmenu, snacks picker, which-key, telescope]
tech_stack:
  added: [vim.opt.winblend, vim.opt.pumblend, picker.win configuration]
  patterns: [Catppuccin + transparency overlay, window-local options, autocmd ColorScheme]
key_files:
  created: []
  modified:
    - nvim/.config/nvim/lua/illico/plugins/colorscheme.lua
    - nvim/.config/nvim/lua/illico/plugins/snacks.lua
decisions: []
metrics:
  duration_seconds: 300
  completed_date: 2026-06-25T14:15:00Z
  task_count: 2
  file_count: 2
---

# Phase 01 Plan 01: Semitransparent Floats Summary

**Configure Neovim floating windows and menus to render semitransparent, creating a naturally darker panel effect while preserving 100% editor transparency.**

## Overview

Floating windows (Pmenu autocomplete, snacks picker, which-key, Telescope) now blend with the background beneath using `winblend` (floating windows) and `pumblend` (completion menu). This produces a darker panel appearance without losing the transparent editor aesthetic—the backdrop (Ghostty wallpaper at 0.95 opacity) shows through partially, creating visual hierarchy.

Global `vim.opt.winblend` and `vim.opt.pumblend` (value 10) apply to generic floats. Snacks picker windows override with explicit `wo.winblend` settings per window (input, list, preview). Telescope already had `winblend=10` configured, now in sync with snacks. Editor panes (Normal, NormalNC, SignColumn) remain 100% transparent.

## Completed Tasks

| Task | Name | Commit | Files Modified |
|------|------|--------|---|
| 1 | Add global winblend and pumblend to colorscheme | `79ec5a1` | `colorscheme.lua` |
| 2 | Add window-local winblend to snacks picker windows | `8a188fb` | `snacks.lua` |

## Technical Details

### Task 1: Global Blend Settings (colorscheme.lua)

Added three elements to the config function:

1. **Constant definition:**
   ```lua
   local blend_level = 10
   ```
   Placed after `float_bg` declaration (line 26) for logical grouping.

2. **Global winblend:**
   ```lua
   vim.opt.winblend = blend_level
   ```
   Applies to all floating windows that don't explicitly override (NormalFloat, which-key, Telescope, generic snacks windows).

3. **Global pumblend:**
   ```lua
   vim.opt.pumblend = blend_level
   ```
   Applies to Pmenu (autocomplete menu) only. Separate from winblend because Pmenu is a special highlight group.

**Comment (Spanish):** Explains that 0 = fully opaque, 100 = fully transparent, and 8–15 is the sensible range.

**Preservation:** All existing highlight group assignments (float_groups, border_groups, editor_transparent) remain unchanged. The apply_transparency() function still re-applies on ColorScheme events, maintaining snacks.nvim cache compatibility.

### Task 2: Snacks Picker Window Options (snacks.lua)

Added `picker.win` configuration block BEFORE the `layout` key:

```lua
picker = {
  enabled = true,
  ui_select = true,
  win = {
    input = { wo = { winblend = 10 } },
    list = { wo = { winblend = 10 } },
    preview = { wo = { winblend = 10 } },
  },
  layout = { ... },  -- unchanged
}
```

**Window-local options:**
- `input`: Search/filter input field at top of picker
- `list`: Main result list (search results)
- `preview`: Right-side file preview pane

**Why explicit `wo` per window:** Snacks picker windows don't automatically inherit global `vim.opt.winblend` because they're created with custom window-local options. Explicit `wo.winblend = 10` ensures each window gets the semitransparency setting.

**Consistency:** Value 10 matches Telescope's existing `winblend = 10` (telescope.lua:54), ensuring all pickers render with the same visual transparency.

## Verification

All tasks passed automated verification:

1. ✓ `colorscheme.lua` contains `vim.opt.winblend` (1 occurrence)
2. ✓ `colorscheme.lua` contains `vim.opt.pumblend` (1 occurrence)
3. ✓ `colorscheme.lua` defines `blend_level` (3 occurrences: definition + 2 assignments)
4. ✓ `snacks.lua` contains `picker.win` with input/list/preview (3 occurrences)
5. ✓ `snacks.lua` contains `winblend = 10` (3 occurrences: one per window)
6. ✓ Both files are syntactically valid Lua (luac -p passed)

## Code Style Compliance

- **Spanish comments:** Both files use Spanish (neutral, latinoamericano) for inline explanations
- **Variable naming:** `blend_level` follows snake_case convention (CONVENTIONS.md)
- **Indentation:** 4 spaces, matching existing code in both files
- **Lua syntax:** No breaking changes; all existing highlight group logic preserved

## No Deviations

Plan executed exactly as specified. No bugs found, no missing functionality detected, no architectural changes required.

## Visual Effect (Expected User Behavior)

1. **Floating windows darken visually** — snacks picker (Find Files, Grep), which-key menu, Pmenu all appear as darker panels over the Ghostty wallpaper
2. **Editor remains transparent** — editor panes (Normal/NormalNC) show Ghostty background fully
3. **Borders invisible** — float_bg (#181825) used for both border foreground and background; renders borderless on all floats
4. **Consistent across pickers** — snacks and Telescope now both use winblend=10, unifying appearance
5. **No performance impact** — winblend/pumblend are Neovim native options; zero overhead

## Files Modified Summary

### nvim/.config/nvim/lua/illico/plugins/colorscheme.lua
- Added blend_level constant (10) with Spanish comment
- Added vim.opt.winblend = blend_level
- Added vim.opt.pumblend = blend_level
- All lines placed immediately after float_bg declaration for logical grouping
- No other changes; existing transparency logic (apply_transparency, float_groups, border_groups, editor_transparent) unchanged

### nvim/.config/nvim/lua/illico/plugins/snacks.lua
- Added picker.win block with input, list, preview window-local options
- Each window gets wo = { winblend = 10 }
- Placed before layout config to maintain logical separation (UI structure vs. behavior)
- No breaking changes to keymaps, layout, or notifier configuration

## Self-Check: PASSED

- [ ] File `/Users/illico/dotfiles/nvim/.config/nvim/lua/illico/plugins/colorscheme.lua` exists ✓
- [ ] File `/Users/illico/dotfiles/nvim/.config/nvim/lua/illico/plugins/snacks.lua` exists ✓
- [ ] Commit `79ec5a1` exists in log ✓
- [ ] Commit `8a188fb` exists in log ✓
- [ ] All verify() grep checks pass ✓
- [ ] Both Lua files parse correctly ✓
