<!-- refreshed: 2026-06-25 -->
# Architecture

**Analysis Date:** 2026-06-25

## System Overview

This is a personal dotfiles repository organized as a collection of tool-specific packages, each deployable independently via symlinks. The deployment model follows GNU stow conventions: each tool package is a self-contained directory containing a shadow directory structure of XDG/home directories (e.g., `nvim/.config/nvim/`, `tmux/.tmux.conf`).

```text
┌──────────────────────────────────────────────────────────────┐
│                    Entry Points                               │
│   Ghostty Terminal  │  Shell (zsh)  │  Text Editor (Nvim)     │
└────────┬────────────┴──────┬────────┴──────────┬──────────────┘
         │                   │                    │
         ▼                   ▼                    ▼
┌──────────────────────────────────────────────────────────────┐
│            Tool Packages (Stow Layout)                        │
│  ghostty/   │   tmux/   │   nvim/   │   taskwarrior/         │
│  claude/    │   (others)                                       │
└──────────────────────────────────────────────────────────────┘
         │                   │                    │
         ▼                   ▼                    ▼
┌──────────────────────────────────────────────────────────────┐
│         XDG/Home Symlink Tree (deployment target)             │
│  ~/.config/ghostty/  │  ~/.tmux.conf  │  ~/.config/nvim/     │
│  ~/.taskrc           │  ~/.task/       │  ~/.zshrc (sourced)  │
└──────────────────────────────────────────────────────────────┘
         │                   │                    │
         ▼                   ▼                    ▼
┌──────────────────────────────────────────────────────────────┐
│               Runtime / Data                                  │
│  Terminal Emulator  │  Tmux Sessions  │  Editor Buffers       │
│  Task Database      │  Shell History  │  Plugin State         │
└──────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | Location |
|-----------|----------------|----------|
| Nvim (Neovim) | Text editor with Lua plugin system, LSP, taskwarrior integration, quarto splits, markdown narrowing | `nvim/.config/nvim/` |
| Tmux | Terminal multiplexer with pane navigation, image passthrough, Neovim integration | `tmux/.tmux.conf`, `tmux/.tmux/scripts/` |
| Ghostty | Terminal emulator with shaders (CRT, cursor smear), transparency, auto-launch tmux | `ghostty/.config/ghostty/` |
| Taskwarrior | Task manager with custom hooks for git, icons, colorization, time tracking | `taskwarrior/.taskrc`, `taskwarrior/.task/hooks/`, `taskwarrior/.task/task-aliases.zsh` |
| Claude CLI Config | Shell aliases and git commit helper using Claude API | `claude/.claude/CLAUDE.md`, `claude/.config/zsh/` |
| Global Instructions | User instructions for Claude interactions (idioma, tone, git policy) | `claude/.claude/CLAUDE.md` |

## Pattern Overview

**Overall:** Stow-based dotfiles with package-per-tool organization.

**Key Characteristics:**
- Each tool is a standalone package with its own XDG directory tree
- Symlinks deployed from repo to `$HOME` using stow (or equivalent manual symlinking)
- Configs are source-able/loadable (e.g., zsh aliases sourced from hooks scripts)
- Cross-tool integration: Nvim + Tmux, Ghostty + Tmux, Taskwarrior hooks + Nvim plugin
- Lua as primary config language for Nvim; Bash/Zsh for scripts and aliases
- Custom hooks and scripts add functionality (Taskwarrior hooks, Tmux scripts, Ghostty shaders)

## Layers

**Entry Point Layer:**
- Purpose: Bootstrap and initialize tool startup
- Location: Tool-specific entry points (`init.lua`, `.tmux.conf`, `config`, `.taskrc`, shell rc files)
- Contains: Core settings, bootstrap logic, plugin initialization
- Depends on: Runtime (Lua VM, shell, terminal)
- Used by: Operating system / shell

**Configuration Layer:**
- Purpose: Define keymaps, options, theme, and behavior
- Location: `nvim/lua/illico/core/`, `tmux/.tmux.conf`, `ghostty/.config/ghostty/`
- Contains: Keymaps, editor options, terminal colors, window behavior
- Depends on: Tool runtime libraries
- Used by: Entry point layer

**Plugin/Extension Layer (Nvim):**
- Purpose: Load and configure third-party plugins
- Location: `nvim/lua/illico/plugins/`, `nvim/.config/nvim/lua/illico/lazy.lua`
- Contains: Plugin specs, plugin-specific configs, LSP configs
- Depends on: Lazy.nvim package manager, core configs
- Used by: Init.lua after core loads

**Integration Layer:**
- Purpose: Connect tools (Nvim ↔ Tmux, Taskwarrior ↔ Nvim, Ghostty ↔ Tmux)
- Location: Taskwarrior hooks (`taskwarrior/.task/hooks/`), Nvim plugins, Shell aliases
- Contains: Cross-tool scripts, hooks, custom functions
- Depends on: All underlying tools
- Used by: Event triggers (task on-add, on-modify; shell aliases)

**Utilities & Helpers:**
- Purpose: Shared scripts, functions, and data processing
- Location: `taskwarrior/.task/hooks/`, `nvim/lua/illico/`, Tmux scripts
- Contains: Post-processors, colorizers, formatters, custom Lua modules
- Depends on: Core tool APIs
- Used by: Config layer and hooks

## Data Flow

### Nvim Startup Sequence

1. **Init Entry** → `nvim/.config/nvim/init.lua` (line 1)
   - Sets `mapleader = " "`
   - Sources core config: `require("illico.core")`
   - Sources plugin manager: `require("illico.lazy")`
   - Sets notification system: `vim.notify = require("snacks").notifier.notify`

2. **Core Config Load** → `nvim/lua/illico/core/init.lua`
   - Requires in order:
     - `illico.core.options` — Editor behavior (indents, line numbers, etc.)
     - `illico.core.keymaps` — Key bindings
     - `illico.core.python` — Python environment config
     - `illico.core.godot` — Godot dev tool config
     - `illico.core.quarto_split` — Quarto document splitting

3. **Plugin System Bootstrap** → `nvim/lua/illico/lazy.lua`
   - Clones/updates lazy.nvim if missing
   - Runs `lazy.setup()` with two spec directories:
     - `illico.plugins` — All plugin configs
     - `illico.plugins.lsp` — LSP-specific configs (mason, lspconfig)
   - Plugin load order determined by lazy.nvim dependency resolution

4. **Plugin Loading** → `nvim/lua/illico/plugins/*.lua`
   - Each file defines one or more plugin specs (table with `url`, `config`, `dependencies`, etc.)
   - On plugin install, configs execute (e.g., telescope keymaps, colorscheme setup)
   - LSP plugins (mason, lspconfig) auto-install language servers defined in config

5. **Runtime** → Editor ready; Lua API available for keymaps, commands, autocmds

### Taskwarrior Task Execution & Post-Processing

1. **User Command** → `task add "thing"` or `task <id> modify ...`
   - Shell wrapper `task()` in `taskwarrior/.task/task-aliases.zsh` intercepts

2. **Preprocessing** → `task()` function (lines 22-50)
   - Parses `-url` / `-file` flags → converts to `link:<value>` UDA
   - Builds args array
   - Calls `command task` (skips wrapper recursion)

3. **Hook Execution** (configured in `.taskrc`)
   - `on-add.effort` — Sets default effort for new tasks
   - `on-modify.effort` — Recalculates urgency when effort changes
   - `on-modify.timewarrior` — Syncs time tracking (if timewarrior installed)
   - Task data modified in-place before DB commit

4. **Report Generation** → `task list` or custom reports
   - Hooks post-process output before display:
     - `colorize-top` — Highlights top task (bold + green)
     - `link-icon` — Appends 🔗 to tasks with `link` UDA
     - `tree-render` — Renders project hierarchy (not always active)

5. **TUI Alternative** → `task-tui()` function
   - Calls `~/.task/hooks/tui` directly
   - Fzf-based picker for task selection

### Ghostty Terminal Launch

1. **Ghostty Start** → Terminal emulator launches
   - Reads `ghostty/.config/ghostty/config`
   - Sets terminal properties: font (JetBrainsMono), theme (Catppuccin Mocha), transparency
   - Applies shaders: `retro-crt.glsl` (scanlines + bloom), `cursor-smear.glsl` (animation)
   - Enables Kitty Graphics Protocol for image passthrough

2. **Command Execution** → `command = /opt/homebrew/bin/tmux new-session -A -s main-$RANDOM`
   - Auto-launches tmux (creates or reattaches to session)
   - Passes control to tmux

3. **Tmux Startup** → `.tmux.conf` loads
   - Sets terminal capabilities (256color, truecolor, italics, undercurl)
   - Enables mouse support
   - Applies vim-style pane keybinds (h/j/k/l)
   - Spawns initial shell (usually zsh)

### Tmux ↔ Nvim Integration

1. **Tmux Focus Events** → `set -g focus-events on`
   - Sends FocusGained/FocusLost events to running programs (e.g., Nvim)
   - Nvim autoread watches for changes to current file (recommended by `:checkhealth`)

2. **Tmux Escape-Time** → `set -sg escape-time 10` (10ms)
   - Low latency so Nvim doesn't hang waiting for Alt-key sequences in Tmux

3. **Image Passthrough** → `set -g allow-passthrough on`
   - Kitty Graphics Protocol passes through Tmux to terminal
   - Nvim plugin `image.nvim` renders PNGs in splits (notebook, quarto)

### Shell Startup (zsh)

1. **Shell RC Sources** → `~/.zshrc` (user's local file, not in repo)
   - May source `claude/.config/zsh/conf.d/claude.zsh`
   - May source `taskwarrior/.config/zsh/conf.d/taskwarrior.zsh`
   - Sourcing is manual or via symlink (user responsibility)

2. **Claude CLI Aliases** → `claude/.config/zsh/conf.d/claude.zsh`
   - `alias claude='command claude --dangerously-skip-permissions'`
   - Defines `ccommit()` — git commit helper using Claude API
     - Stages all changes if none staged
     - Generates commit message via Claude (opus, medium effort)
     - Shows diff and prompts for edit/confirm/cancel
     - Creates commit with `git commit -F -`

3. **Taskwarrior Wrapper** → `claude/.config/zsh/conf.d/taskwarrior.zsh`
   - Defines `task()` wrapper (see Taskwarrior data flow above)

## Key Abstractions

**Package Structure (Stow):**
- Purpose: Organize configs by tool, deploy to home via symlinks
- Examples: `nvim/`, `tmux/`, `ghostty/`, `taskwarrior/`, `claude/`
- Pattern: Each package contains a shadow of `$HOME` file tree (e.g., `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`)

**Lua Namespace (Nvim `illico.*`):**
- Purpose: Organize Nvim configs in Lua modules, avoid global namespace pollution
- Examples: `illico.core.*`, `illico.plugins.*`, `illico.plugins.lsp.*`
- Pattern: Require statements build dependency graph; lazy.nvim resolves

**Plugin Spec (Lazy.nvim):**
- Purpose: Declare plugin source, dependencies, config, and load conditions
- Examples: `lsp/lspconfig.lua` specs mason + lspconfig + handlers
- Pattern: Each file is a table or function returning tables; lazy.nvim reads and installs

**Taskwarrior Hook Chaining:**
- Purpose: Intercept task events (add, modify) and post-process output
- Examples: `on-add.effort`, `colorize-top`, `link-icon`
- Pattern: Hooks are executables in `~/.task/hooks/`; referenced in `.taskrc` as `hooks.location`

**Shell Wrapper Functions:**
- Purpose: Extend CLI tools with custom logic (preprocessing, post-processing)
- Examples: `task()` in zsh, `ccommit()` in zsh
- Pattern: Wrapper uses `command <tool>` to avoid recursion, pipes and processes output

## Entry Points

**Nvim:**
- Location: `nvim/.config/nvim/init.lua`
- Triggers: `nvim <file>` or `nvim` (opens editor)
- Responsibilities:
  - Set leader key
  - Load core config (options, keymaps, integrations)
  - Initialize lazy.nvim plugin manager
  - Configure notification system

**Tmux:**
- Location: `tmux/.tmux.conf`
- Triggers: `tmux new-session` (auto-launched by Ghostty)
- Responsibilities:
  - Set terminal capabilities (colors, escape time, focus events)
  - Enable mouse and image passthrough
  - Define pane navigation/resizing keybinds
  - Configure appearance (status bar, etc.)

**Ghostty:**
- Location: `ghostty/.config/ghostty/config`
- Triggers: Ghostty app launch
- Responsibilities:
  - Font and theme configuration
  - Shader pipeline (CRT + cursor smear)
  - Window behavior (non-native fullscreen for QuartoSplit)
  - Auto-launch tmux command

**Taskwarrior:**
- Location: `taskwarrior/.taskrc`
- Triggers: `task <command>` (via shell wrapper)
- Responsibilities:
  - Data location and hook configuration
  - Report definitions (list, calendar, notes)
  - Color scheme (Catppuccin-inspired)
  - Custom UDA definitions (effort, note, link)

**Claude CLI Config:**
- Location: `claude/.claude/CLAUDE.md`
- Triggers: Manual source or symlink in Claude desktop app config
- Responsibilities:
  - User language preferences (Spanish without rioplatense)
  - Tone guidelines (no meta-commentary, no "honestidad" announcements)
  - Git policy (no Co-Authored-By, always commit after work)
  - CriticMarkup task handling rules

**Shell Integration:**
- Location: Shell RC files (user's `~/.zshrc`)
- Triggers: Shell startup
- Responsibilities:
  - Source Claude aliases and ccommit function
  - Source Taskwarrior wrapper and aliases
  - Optional: Source engram zsh hooks (Engram memory system)

## Architectural Constraints

- **Symlink-based deployment:** Tools are configured in repo; changes don't take effect until stow/symlinks are updated. Manual edits in `~/.config/` will be overwritten on stow re-apply.
  
- **Lua-only Nvim config:** No vimscript; all config is Lua (init.lua requires Lua runtime, lazy.nvim requires vim.fn/vim.opt APIs).

- **Stow package isolation:** Each package is independent; shared code (e.g., scripts used by multiple tools) must be duplicated or symlinked within packages.

- **Terminal capability stack:** Ghostty → Tmux → Nvim. Ghostty sets initial TERM; Tmux overrides with `screen-256color` but restores truecolor via terminal-overrides. Nvim reads environment and detects capabilities.

- **Hook execution order in Taskwarrior:** Hooks run in alphabetical order by filename. No explicit control over sequencing; if order matters, must name files accordingly (e.g., `00-first`, `99-last`).

- **Image passthrough dependency:** `allow-passthrough on` in Tmux + Kitty Graphics Protocol + Ghostty shader pipeline → `image.nvim` can render images. Missing any link breaks rendering.

- **Global state in Lua Nvim:** Plugin configs read/write to vim.opt, vim.g, vim.b tables. No local module state persists between buffer switches unless manually cached (see `illico.narrow.lua` counter).

## Anti-Patterns

### Direct Home-Directory Edits Overwrites on Stow Re-Apply

**What happens:** User edits `~/.config/nvim/init.lua` directly instead of editing `nvim/.config/nvim/init.lua` in repo.

**Why it's wrong:** Next `stow -S nvim` (or equivalent) symlinks repo version over edited file, losing local changes.

**Do this instead:** Always edit files in the dotfiles repo (`nvim/.config/nvim/init.lua`), then commit and re-apply stow if needed. Use git to track all config changes.

### Hardcoded Absolute Paths in Scripts

**What happens:** Taskwarrior hooks or shell scripts reference `/Users/illico/dotfiles/` directly instead of using `$HOME` or `$DOTFILES` variables.

**Why it's wrong:** Scripts break if repo is moved or symlinked to different location; not portable across machines.

**Do this instead:** Use `$HOME`, `$DOTFILES` (if defined), or `$(cd "$(dirname "$0")" && pwd)` for relative paths. See `taskwarrior/.task/task-aliases.zsh` lines 37-42 for example of proper path resolution.

### Plugin Configs Modifying Global Vim State Without Isolation

**What happens:** A plugin spec in `illico.plugins/` sets vim.g.some_option without checking if it's already set or conflicting with another plugin.

**Why it's wrong:** Plugin load order (determined by lazy.nvim) becomes implicit dependency; changes to load order break configs.

**Do this instead:** Use lazy.nvim's `priority` and `dependencies` fields to enforce explicit ordering. Isolate config within plugin spec's `config()` function or auto-command.

### Taskwarrior Hook Scripts Assuming Unix Tools Availability

**What happens:** Hook script uses `sed`, `awk`, `perl` without checking if available (may not be on minimal systems or inside containers).

**Why it's wrong:** Task adds/modifies fail silently or with cryptic errors if tool is missing.

**Do this instead:** Either ship critical scripts in repo (already done: `colorize-top`, `tree-render`) or use only Taskwarrior's built-in features (UDAs, reports, formats).

## Error Handling

**Strategy:** Layered fallback; scripts degrade gracefully.

**Patterns:**
- **Nvim lazy.nvim:** If plugin clone fails, lazy.nvim shows error message and continues (plugins with install errors marked in UI)
- **Taskwarrior hooks:** If hook returns non-zero, task operation is aborted with error message; user must fix hook
- **Shell wrappers:** Use `|| { print -u2 "error"; return 1 }` to report and exit early
- **Tmux terminal capabilities:** Fallback from tmux-256color to screen-256color if terminfo missing; truecolor restored via terminal-overrides

## Cross-Cutting Concerns

**Logging:** 
- Nvim: Uses `vim.notify()` (redirected to snacks.notifier) for user-visible messages
- Taskwarrior: Outputs to stdout/stderr in hooks; errors shown in task CLI output
- Shell: Uses `print` (zsh) with `-u2` for stderr, color ANSI codes for terminal output

**Validation:**
- Nvim: Plugin specs validated by lazy.nvim at startup; malformed specs fail early
- Taskwarrior: Hook scripts responsible for validation; `.taskrc` validated by taskwarrior CLI on read
- Shell: No runtime validation; user responsible for correct syntax in `.zshrc` / hook scripts

**Authentication:**
- Claude CLI: Reads API key from env (likely `CLAUDE_API_KEY` or `~/.claude/credentials`); managed externally (not in this repo per `.gitignore`)
- Taskwarrior: No auth (local database); git integration (`task-git.sh` hook) authenticates via SSH key or token

---

*Architecture analysis: 2026-06-25*
