# Roadmap: Dotfiles — Ajustes gráficos de Neovim

**Project:** Dotfiles — Ajustes gráficos de Neovim  
**Created:** 2026-06-25  
**Granularity:** Coarse (5 phases)  
**Mode:** MVP  
**Coverage:** 6/6 requirements mapped ✓

---

## Phases

- [x] **Phase 1: Semitransparent Floats** - Configure float backgrounds with transparency blending
- [ ] **Phase 2: Tunnelvision Plugin** - Install and configure tunnelvision.nvim with toggle
- [ ] **Phase 3: Real-icons Verification** - Verify real-icons.nvim chain end-to-end
- [ ] **Phase 4: tmux "Claude Done" Indicator** - Implement bell glyph notification with reliable hook versioning
- [ ] **Phase 5: Repository Closure** - Commit all changes and verify clean tree

---

## Phase Details

### Phase 1: Semitransparent Floats
**Goal:** Float windows (menus, autocomplete, etc.) render semitransparent, producing a naturally darker panel effect while preserving borderless aesthetic and editor transparency.
**Mode:** mvp
**Depends on:** Nothing (first phase)
**Requirements:** FLOAT-01
**Success Criteria** (what must be TRUE):
  1. `colorscheme.lua` defines float background color with transparency blend (not 100% opaque)
  2. Float group highlights have blend/opacity setting applied
  3. Border and corner styles remain unchanged (borderless, no rounded corners)
  4. Editor transparency (`Normal`/`NormalNC`) remains unaffected at 100%
**Plans:**
- [x] 01-01-PLAN.md — Add vim.opt.winblend and vim.opt.pumblend to apply transparency blending to floating windows and Pmenu

### Phase 2: Tunnelvision Plugin
**Goal:** Tunnelvision.nvim is installed and configured with a dedicated toggle keybinding that does not interfere with existing keymaps or plugins.
**Mode:** mvp
**Depends on:** Phase 1
**Requirements:** TUNNEL-01
**Success Criteria** (what must be TRUE):
  1. Tunnelvision.nvim plugin spec exists in lazy.nvim configuration
  2. Toggle keybinding `<leader>tv` is defined and verified not to collide with existing keymaps (`tb`, `ths`, `tw`, `tz`)
  3. Plugin loads without errors and toggle is functional
  4. No other plugins or keymaps are affected by the addition
**Plans:**
- [ ] 02-01-PLAN.md — Create tunnelvision.lua plugin spec with lazy-loaded <leader>tv toggle

### Phase 3: Real-icons Verification
**Goal:** Real-icons.nvim chain is verified end-to-end at the code/config level: plugin installed, pack `material` available, ImageMagick available, tmux passthrough active, and fallback rendering configured.
**Mode:** mvp
**Depends on:** Phase 1
**Requirements:** ICONS-01
**Success Criteria** (what must be TRUE):
  1. Real-icons.nvim plugin spec exists with `build = ":RealIconsInstallPack material"` and `mini_files = false`
  2. ImageMagick (`magick`) is available at `/opt/homebrew/bin/magick`
  3. Tmux config has `allow-passthrough on` set for Kitty Graphics Protocol
  4. Fallback icon rendering (glyphs) is configured in real-icons.lua
**Plans:** TBD

### Phase 4: tmux "Claude Done" Indicator
**Goal:** Tmux displays a reliable "Claude finished" notification using the bell glyph (U+F0F3) in red next to the window tab, with the hook that triggers it versioned in the repository and integrated with stow deployment.
**Mode:** mvp
**Depends on:** Phase 3 (tmux config validation)
**Requirements:** NOTIFY-01, NOTIFY-02
**Success Criteria** (what must be TRUE):
  1. Bell glyph U+F0F3 in red replaces exclamation-circle U+F06A in both `window-status-format` and `window-status-current-format` in `tmux/.tmux.conf`
  2. Hook file `claude/.claude/hooks/tmux-claude-done.sh` exists in repo and is symlinked via stow to `~/.claude/hooks/tmux-claude-done.sh`
  3. Hook version tracking in repo enables reliable Stop event handling without loss due to SubagentStop events
  4. Indicator shows only on non-active windows and clears on select (existing logic preserved and verified across GSD/subagent runs)
**Plans:** TBD

### Phase 5: Repository Closure
**Goal:** All changes across phases 1–4 (nvim config, tmux config, claude hook) are committed to git with a clean working tree, establishing a stable baseline.
**Mode:** mvp
**Depends on:** Phase 4 (all feature work complete)
**Requirements:** REPO-01
**Success Criteria** (what must be TRUE):
  1. All modified files in `nvim/.config/nvim/`, `tmux/.tmux.conf`, and `claude/.claude/hooks/` are staged and committed
  2. Commit message documents all four feature changes (floats, tunnelvision, real-icons verification, tmux indicator)
  3. `git status` shows a clean tree (no unstaged, untracked, or staged files)
  4. Recent commit log includes the closure commit with all changes
**Plans:** TBD

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Semitransparent Floats | 1/1 | Complete   | 2026-06-25 |
| 2. Tunnelvision Plugin | 0/1 | Planned | - |
| 3. Real-icons Verification | 0/1 | Not started | - |
| 4. tmux "Claude Done" Indicator | 0/1 | Not started | - |
| 5. Repository Closure | 0/1 | Not started | - |

---

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| FLOAT-01 | Phase 1 | Planned |
| TUNNEL-01 | Phase 2 | Planned |
| ICONS-01 | Phase 3 | Pending |
| NOTIFY-01 | Phase 4 | Pending |
| NOTIFY-02 | Phase 4 | Pending |
| REPO-01 | Phase 5 | Pending |

**Coverage:** 6/6 ✓

---

*Roadmap created: 2026-06-25*
*Revised: 2026-06-25 to add Phase 4 (tmux indicator) and renumber closure to Phase 5*
*Plans created: 2026-06-25 Phase 1; 2026-06-25 Phase 2*
