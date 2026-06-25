# Codebase Structure

**Analysis Date:** 2026-06-25

## Directory Layout

```
dotfiles/
├── .claude/                              # Claude CLI local config (symlink target)
│   ├── CLAUDE.md                         # Global instructions for Claude (idioma, tone, git policy)
│   ├── projects/                         # Project-scoped instructions (not in this repo)
│   └── skills/                           # GSD skills (skills.md index files)
│
├── .planning/                            # GSD planning outputs (generated)
│   └── codebase/                         # This directory (ARCHITECTURE.md, STRUCTURE.md, etc.)
│
├── .git/                                 # Git repository
│
├── nvim/                                 # Neovim config package
│   └── .config/nvim/
│       ├── init.lua                      # Entry point: loads core + lazy.nvim
│       ├── lazy-lock.json                # Plugin lockfile
│       ├── colors/
│       │   └── superset.lua              # Custom colorscheme
│       ├── ftplugin/
│       │   └── markdown.lua              # Markdown-specific settings
│       └── lua/illico/
│           ├── core/
│           │   ├── init.lua              # Loads core modules in order
│           │   ├── options.lua           # Editor behavior (indents, UI, etc.)
│           │   ├── keymaps.lua           # Key bindings
│           │   ├── python.lua            # Python env integration
│           │   ├── godot.lua             # Godot dev tool setup
│           │   └── quarto_split.lua      # Quarto document splitting
│           ├── lazy.lua                  # Bootstrap + setup lazy.nvim
│           ├── narrow.lua                # Markdown section narrowing (full-screen edit)
│           └── plugins/
│               ├── *.lua                 # ~46 plugin configs (one file per plugin)
│               │   Examples:
│               │   - aerial.lua          # Code structure outline
│               │   - telescope.lua       # Fuzzy finder
│               │   - lsp/
│               │   │   ├── lspconfig.lua # Language server setup
│               │   │   └── mason.lua     # LSP server auto-installer
│               │   - taskwarrior.lua     # Integration: task picker in Nvim
│               │   - codecompanion.lua   # AI assistant in editor
│               │   - vimtex.lua          # LaTeX editing
│               │   - render-markdown.lua # Markdown preview
│               │   - snacks.lua          # Notifications + UI utilities
│               │   - git.lua             # Git fugitive + gitsigns
│               │   - treesitter.lua      # Syntax parsing
│               │   - which-key.lua       # Keymap hints
│               │   - trouble.lua         # Diagnostics list
│               │   - colorscheme.lua     # Theme initialization
│               │   - and 32 more...
│
├── tmux/                                 # Tmux config package
│   ├── .tmux.conf                        # Entry point: terminal settings, keybinds
│   └── .tmux/
│       └── scripts/
│           ├── quarto-tile.sh            # Quarto document split layout helper
│           └── qpreview.swift            # (macOS) Quarto preview handler
│
├── ghostty/                              # Ghostty terminal emulator package
│   └── .config/ghostty/
│       ├── config                        # Entry point: term settings, font, theme, shaders
│       └── shaders/
│           ├── retro-crt.glsl            # CRT scanlines + bloom effect
│           └── cursor-smear.glsl         # Cursor animation shader
│
├── taskwarrior/                          # Taskwarrior task manager package
│   ├── .taskrc                           # Entry point: data location, hooks, reports, color
│   ├── .task/
│   │   ├── task-aliases.zsh              # Shell wrapper for `task()` command + `task-tui()`
│   │   └── hooks/
│   │       ├── on-add.effort             # Set default effort for new tasks
│   │       ├── on-modify.effort          # Recalculate urgency when effort changes
│   │       ├── on-modify.timewarrior     # Sync to timewarrior (time tracking)
│   │       ├── colorize-top              # Make top task green+bold
│   │       ├── link-icon                 # Append 🔗 to tasks with links
│   │       ├── tree-render               # Render project tree (optional)
│   │       ├── project-note              # Project-level annotations
│   │       ├── note                      # Note management helper
│   │       ├── tui                       # Fzf-based task picker TUI
│   │       ├── tui-note                  # Note editor for tasks
│   │       ├── split                     # Project split/subtask helper
│   │       ├── select                    # (deprecated?) task selection
│   │       ├── task-git.sh               # Git integration for task changes
│   │       └── __pycache__/              # Compiled Python hooks cache
│   └── .config/zsh/
│       └── conf.d/
│           └── taskwarrior.zsh           # (symlink target) Zsh aliases + task() wrapper
│
├── claude/                               # Claude CLI integration package
│   ├── .claude/
│   │   ├── CLAUDE.md                     # Global instructions (idioma, tone, git commits)
│   │   └── skills/                       # GSD agent skills (directories with SKILL.md + rules/)
│   │       ├── banner-creator/
│   │       ├── gsd-debug/
│   │       ├── gsd-stats/
│   │       ├── mvp-builder/
│   │       ├── build-with-agent-team/
│   │       ├── gsd-ns-context/
│   │       ├── gsd-code-review/
│   │       ├── gsd-discuss-phase/
│   │       ├── gsd-update/
│   │       ├── gsd-surface/
│   │       ├── gsd-undo/
│   │       ├── gsd-plan-phase/
│   │       ├── gsd-config/
│   │       ├── gsd-fast/
│   │       ├── gsd-ingest-docs/
│   │       ├── gsd-audit-uat/
│   │       ├── gsd-apply-changes/
│   │       ├── gsd-parallel-test/
│   │       ├── gsd-apply-pr-feedback/
│   │       └── ... (more skills)
│   └── .config/zsh/
│       └── conf.d/
│           ├── claude.zsh               # CLI aliases + ccommit() git helper
│           └── engram.zsh               # (symlink target) Engram memory system setup
│
├── test_files/                           # Test/output directory (for quarto rendering)
├── test.qmd                              # Quarto markdown test file
├── test.html                             # Rendered output
├── test.quarto_ipynb                     # Quarto notebook outputs
├── custom.scss                           # Custom stylesheet (test?)
├── .gitignore                            # Excludes: .env, *.env, credentials, .task/*, test files
└── (root git files)
```

## Directory Purposes

**nvim/.config/nvim/:**
- Purpose: Neovim configuration and plugins
- Contains: Lua configs, plugin specs, theme colors, filetype-specific settings
- Key files:
  - `init.lua` (entry point)
  - `lua/illico/lazy.lua` (plugin manager bootstrap)
  - `lua/illico/core/*.lua` (core settings)
  - `lua/illico/plugins/*.lua` (plugin configs)

**tmux/.tmux.conf:**
- Purpose: Tmux session multiplexer configuration
- Contains: Keybinds, terminal settings, status bar, pane navigation
- Key files:
  - `.tmux.conf` (entry point, ~200+ lines)
  - `.tmux/scripts/` (helper scripts for special layouts)

**ghostty/.config/ghostty/:**
- Purpose: Ghostty terminal emulator configuration
- Contains: Font, theme (Catppuccin), transparency, shaders (CRT, cursor smear)
- Key files:
  - `config` (entry point, ~58 lines)
  - `shaders/*.glsl` (GLSL shader programs for visual effects)

**taskwarrior/.taskrc:**
- Purpose: Taskwarrior task manager configuration
- Contains: Data location, hook definitions, reports, color theme, custom UDAs
- Key files:
  - `.taskrc` (entry point, 80+ lines)
  - `.task/hooks/` (executable post-processors)
  - `.task/task-aliases.zsh` (shell wrapper)

**claude/.claude/CLAUDE.md:**
- Purpose: User instructions for Claude interactions
- Contains: Language preferences (Spanish neutral), tone rules, git policy, CriticMarkup handling
- Key files:
  - `CLAUDE.md` (entry point, ~28 lines)
  - `skills/` (GSD agent skill definitions, not detailed here; see individual SKILL.md files)

**claude/.config/zsh/conf.d/:**
- Purpose: Zsh shell integrations for Claude CLI and memory system
- Contains: Aliases, helper functions
- Key files:
  - `claude.zsh` (aliases + ccommit git helper)
  - `engram.zsh` (symlink target for Engram memory system)

## Key File Locations

**Entry Points:**

| Tool | Entry Point | Purpose |
|------|-------------|---------|
| Nvim | `nvim/.config/nvim/init.lua` | Load core + plugins |
| Tmux | `tmux/.tmux.conf` | Configure session multiplexer |
| Ghostty | `ghostty/.config/ghostty/config` | Configure terminal emulator |
| Taskwarrior | `taskwarrior/.taskrc` | Configure task manager + hooks |
| Claude CLI | `claude/.claude/CLAUDE.md` | User instructions (symlink to ~/.claude/CLAUDE.md) |
| Zsh | (user's `~/.zshrc`) | Sources `claude/.config/zsh/conf.d/claude.zsh` + taskwarrior wrappers |

**Configuration:**

| Tool | Config Location | Purpose |
|------|-----------------|---------|
| Nvim core | `nvim/.config/nvim/lua/illico/core/` | Options, keymaps, language-specific settings |
| Nvim plugins | `nvim/.config/nvim/lua/illico/plugins/` | Individual plugin specs and configs |
| Tmux keybinds | `tmux/.tmux.conf` (lines 34-50) | Pane navigation (hjkl) and resize (HJKL) |
| Ghostty theme | `ghostty/.config/ghostty/config` (lines 9-33) | Catppuccin Mocha palette, font, size |
| Ghostty shaders | `ghostty/.config/ghostty/config` (lines 46-52) | CRT + cursor smear pipeline |
| Taskwarrior colors | `taskwarrior/.taskrc` (lines 28-50) | Per-status color rules |
| Taskwarrior reports | `taskwarrior/.taskrc` (lines 52-65) | Custom list, calendar, notes views |
| Taskwarrior UDAs | `taskwarrior/.taskrc` (lines 68-80+) | Custom fields (effort, note, link) |

**Core Logic:**

| Component | File | Responsibility |
|-----------|------|-----------------|
| Nvim module loading | `nvim/.config/nvim/lua/illico/core/init.lua` | Orchestrates core submodule loads |
| Nvim plugin manager | `nvim/.config/nvim/lua/illico/lazy.lua` | Bootstraps and configures lazy.nvim |
| Task wrapper logic | `taskwarrior/.task/task-aliases.zsh` | Intercepts task CLI, preprocesses args, post-processes output |
| Git integration | `taskwarrior/.task/hooks/task-git.sh` | Syncs task changes to git history |
| Taskwarrior TUI | `taskwarrior/.task/hooks/tui` | Fzf-based interactive task picker |
| Markdown narrowing | `nvim/.config/nvim/lua/illico/narrow.lua` | Opens markdown sections full-screen for editing |
| Quarto splits | `nvim/.config/nvim/lua/illico/core/quarto_split.lua` | Quarto document layout helpers |
| Git commit helper | `claude/.config/zsh/conf.d/claude.zsh` (lines 8-77) | `ccommit()` function: generates commit messages via Claude API |

**Testing:**

No dedicated test suite found. Repository contains:
- `test.qmd` — Quarto markdown file (test/example)
- `test.html`, `test.quarto_ipynb*` — Rendered outputs
- `test_files/` — Support files for quarto rendering
- `custom.scss` — Custom stylesheet (test?)

(These are likely ad-hoc test outputs, not automated test infrastructure.)

## Naming Conventions

**Files:**

- **Init files:** `init.lua` (Nvim entry point), `.tmux.conf` (Tmux), `config` (Ghostty), `.taskrc` (Taskwarrior)
- **Shell scripts (executable):** No extension (e.g., `colorize-top`, `tui`, `split`), shebang on line 1
- **Lua modules:** `.lua` extension, CamelCase for files matching function/class names (e.g., `narrow.lua` → `M = {}` module)
- **Config files:** No extension (`.taskrc`, `.tmux.conf`) or named directly (`.config/ghostty/config`)
- **Lockfiles:** JSON (e.g., `lazy-lock.json` for Nvim plugin versions)

**Directories:**

- **XDG standard:** `.config/`, `.task/`, `.tmux/` mirror home directory structure
- **Tool packages:** Lowercase singular (e.g., `nvim`, `tmux`, `ghostty`, `taskwarrior`, `claude`)
- **Lua namespaces:** Lowercase with dots (e.g., `illico.core`, `illico.plugins`, `illico.plugins.lsp`)
- **Hook directories:** `.task/hooks/` (Taskwarrior), `.tmux/scripts/` (Tmux)
- **Config subdirs:** `.config/zsh/conf.d/` for modular zsh configs

**Variables & Functions (Lua/Zsh):**

- **Lua:** `camelCase` for variables/functions (e.g., `sectionRange()`, `M.narrow()`)
- **Zsh:** `lowercase_with_underscores` for local functions (e.g., `ccommit()`, `task()`, `task-tui()`)
- **Environment:** `UPPERCASE` (e.g., `$DOTFILES`, `$HOME`, `$CLAUDE_API_KEY`)

## Where to Add New Code

**New Nvim Plugin Config:**
- File location: `nvim/.config/nvim/lua/illico/plugins/<plugin-name>.lua`
- Pattern: Return a plugin spec table with `url`, `config`, `dependencies`, `keys`, `cmd`, etc.
- Example from existing: `nvim/.config/nvim/lua/illico/plugins/telescope.lua` defines keymaps + config
- Lazy.nvim auto-discovers files in `illico.plugins` directory (see `lazy.lua` line 24: `{ import = "illico.plugins" }`)

**New Nvim Core Setting:**
- File location: `nvim/.config/nvim/lua/illico/core/<setting-name>.lua` (if new category) OR add to existing file (e.g., `options.lua`)
- Pattern: Directly set vim.opt/vim.g/vim.b
- Must be required from `nvim/.config/nvim/lua/illico/core/init.lua` to load
- Example: `nvim/.config/nvim/lua/illico/core/python.lua` sets Python-specific env vars

**New Taskwarrior Hook:**
- File location: `taskwarrior/.task/hooks/<hook-name>` (no extension, executable, shebang)
- Pattern: Read JSON from stdin, process task data, output modified JSON (or error)
- Must be referenced in `taskwarrior/.taskrc` (e.g., `hooks.on-add=~/.task/hooks/on-add.effort`)
- Registration in `.taskrc`:
  - On-add hook: `hooks.on-add` (runs before add)
  - On-modify hook: `hooks.on-modify` (runs before modify)
  - Post-process (report): Use in `report.<name>.filter` or custom shell wrapper
- Example: `taskwarrior/.task/hooks/colorize-top` outputs ANSI color codes

**New Taskwarrior Shell Alias:**
- File location: `taskwarrior/.task/task-aliases.zsh` OR `taskwarrior/.config/zsh/conf.d/taskwarrior.zsh`
- Pattern: Zsh function wrapping `command task` or standalone function
- Must be sourced from user's `~/.zshrc`
- Example: `task-tui()` calls `"$HOME/.task/hooks/tui"` directly

**New Tmux Helper Script:**
- File location: `tmux/.tmux/scripts/<script-name>` (bash or shell script)
- Pattern: Standalone executable; called from `.tmux.conf` via `run-shell` or `send-keys`
- Example: `tmux/.tmux/scripts/quarto-tile.sh` creates split layout for quarto docs

**New Ghostty Shader:**
- File location: `ghostty/.config/ghostty/shaders/<shader-name>.glsl`
- Pattern: GLSL fragment shader; referenced in `config` as `custom-shader = shaders/<name>.glsl`
- Ghostty applies in order (compositing); multiple shaders allowed
- Example: `shaders/retro-crt.glsl` (scanlines) + `shaders/cursor-smear.glsl` (animation)

**New Claude Skill:**
- File location: `claude/.claude/skills/<skill-name>/SKILL.md` + `rules/*.md`
- Pattern: SKILL.md is index; rules/ contains implementation (see individual skills)
- Not modified directly; managed by GSD orchestrator
- Reference: `claude/.claude/skills/` already has 20+ skills installed

**New Tool Package (if adding support for new tool):**
1. Create directory: `<tool>/.config/<tool>/` (or `<tool>/.<tool>/` or `<tool>/.config/` depending on XDG standard for tool)
2. Create entry point: `<tool>/.config/<tool>/config` (or equivalent, following XDG structure)
3. Add symlink instructions to repo README or stow manifest
4. Commit to git

## Special Directories

**`.planning/codebase/`:**
- Purpose: GSD codebase maps (ARCHITECTURE.md, STRUCTURE.md, etc.)
- Generated: Yes (by `/gsd:map-codebase` agent)
- Committed: Yes (to track codebase analysis results)
- Notes: Incremental; new docs replace old ones; not user-editable

**`.claude/skills/`:**
- Purpose: GSD agent skill definitions (for `/gsd:execute-phase`, `/gsd:plan-phase`, etc.)
- Generated: No (installed manually or via GSD orchestrator)
- Committed: Yes (project dependencies)
- Notes: Each skill is a directory with SKILL.md + rules/; read-only by Claude during execution

**`nvim/.config/nvim/colors/`:**
- Purpose: Custom Neovim colorschemes
- Generated: No (user-defined)
- Committed: Yes (theming)
- Contains: Lua files defining highlight groups (e.g., `superset.lua` = custom theme)

**`tmux/.tmux/scripts/`:**
- Purpose: Helper scripts for Tmux (not core config)
- Generated: No (user-defined)
- Committed: Yes (reusable utilities)
- Contains: Bash/shell scripts for layouts, previews, etc.

**`ghostty/.config/ghostty/shaders/`:**
- Purpose: GLSL shaders for terminal visual effects
- Generated: No (user-defined)
- Committed: Yes (visual configuration)
- Contains: Fragment shaders (e.g., retro-crt, cursor-smear)

**`taskwarrior/.task/`:**
- Purpose: Taskwarrior data + hooks
- Generated: Partially (database in `task/` is auto-generated during `task` init)
- Committed: Hooks only (git-ignored files: `.task/*.data`, `.task/backlog.data`, etc.)
- Contains: Custom hooks (executable), task database (auto-generated), logs

**`taskwarrior/.config/zsh/conf.d/`:**
- Purpose: Symlink targets for Zsh integration
- Generated: No (repo version)
- Committed: Yes (shell integration)
- Notes: User's `~/.config/zsh/conf.d/` should symlink to or source `dotfiles/taskwarrior/.config/zsh/conf.d/taskwarrior.zsh`

---

*Structure analysis: 2026-06-25*
