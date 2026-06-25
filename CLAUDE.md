<!-- GSD:project-start source:PROJECT.md -->
## Project

**Dotfiles — Ajustes gráficos de Neovim**

Milestone de pulido visual sobre la configuración de Neovim dentro de este repo de dotfiles (stow, macOS, Catppuccin Mocha sobre Ghostty + tmux transparentes). Cubre tres cambios concretos: hacer los menús/flotantes semitransparentes, integrar el plugin `tunnelvision.nvim` con un toggle propio, y verificar que la cadena de `real-icons.nvim` renderiza iconos reales como el plugin pretende.

**Core Value:** La config de Neovim se ve y se comporta como el usuario quiere: menús con un panel naturalmente más oscuro (no 100% opaco), sin romper la transparencia del editor ni la estética sin bordes ya establecida.

### Constraints

- **Estética**: Menús sin borde y sin esquinas redondeadas — invariante, no se toca.
- **Transparencia**: El editor (`Normal`/`NormalNC`/`SignColumn`) sigue 100% transparente; solo cambian los flotantes.
- **No-interferencia**: El toggle de tunnelvision (`<leader>tv`) no debe pisar keymaps existentes ni alterar otros plugins.
- **Tech stack**: Lua + lazy.nvim; editar en el repo (stow), nunca en `~/.config` directo.
- **Cierre**: commit de todos los cambios + clean tree al finalizar.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Lua - Neovim configuration and plugins (`nvim/.config/nvim/lua/`)
- Shell (Bash, Zsh) - Tmux scripts, task hooks, shell configuration
- GLSL - Custom shader programs for Ghostty terminal (`ghostty/.config/ghostty/shaders/`)
- Swift - macOS integration utilities (`tmux/.tmux/scripts/qpreview.swift`)
- Python - Data processing and utilities (taskwarrior hooks use Python 3)
## Runtime
- Neovim 0.11+ (recent treesitter integration, LSP features)
- Lua 5.1+ (embedded in Neovim)
- Zsh (primary shell)
- Bash 3.2+ (macOS system bash)
- Python 3.x (via `/opt/homebrew/bin/python3`)
- **Neovim plugins:** lazy.nvim (bootstrap at `nvim/.config/nvim/lua/illico/lazy.lua`)
- **Tmux plugins:** tpm (Tmux Plugin Manager, bootstraps from `~/.tmux/plugins/tpm`)
- **Taskwarrior:** Built-in hook system (Python-based)
## Frameworks
- **Neovim LSP** - Language Server Protocol for code intelligence
- **lazy.nvim** - Plugin manager for Neovim
- **Snacks.nvim** - Utility framework (notifications, pickers, window management)
- **Noice.nvim** - Enhanced command/notification UI
- **Which-key.nvim** - Keybinding help menu
- **Telescope.nvim** - Fuzzy finder and picker
- **Conform.nvim** - Code formatter wrapper (Prettier, Stylua, isort)
- **Nvim-lint** - Asynchronous linter integration
- **nvim-cmp** - Autocompletion engine with multiple sources
- **Catppuccin/nvim** - Color scheme (Mocha flavor)
- **Real-icons.nvim** - Graphics protocol icon rendering (Ghostty backend)
- **Mini.* modules** - UI components (files, icons, splitjoin, surround, animate)
- **Lualine.nvim** - Statusline with buffer tabs
- **Treesitter** (nvim-treesitter) - AST parsing and syntax highlighting
- **Quarto-nvim** - Quarto document support (R/Python notebooks)
- **VimTeX** - LaTeX editing (via Tectonic engine)
- **Orgmode** - Org-mode support
- **Neorg** - Knowledge base system (with captures and templates)
- **Image.nvim** - Image rendering in editor
- **Img-clip.nvim** - Screenshot/clipboard image handling
- **Markdown-preview.nvim** - Markdown preview in browser
- **Render-markdown.nvim** - Markdown rendering in editor
- **Aerial.nvim** - Code outline sidebar
- **Leap.nvim** - Lightweight motion plugin (Codeberg source: https://codeberg.org/andyg/leap.nvim)
- **Focus.nvim** - Automatic window focusing
- **Vim-maximizer** - Window maximize/minimize
- **Mini.files** - File explorer
- **Gitsigns.nvim** - Git diff signs and hunks
- **Lazygit.nvim** - Lazygit terminal UI integration
- **Tmux** - Terminal multiplexer with custom configuration
- **Ghostty** - Modern GPU-accelerated terminal emulator
- **GDScript LSP** - Direct TCP connection to Godot Editor (port 6005)
- **GDShader Language Server** (gdshader-language-server)
## Key Dependencies
- **Mason.nvim** - Unified package manager for LSP servers and tools
- **Lazy.nvim** - 80+ plugins managed via lazy-loading spec
- **prettier** - JavaScript/TypeScript formatter
- **stylua** - Lua formatter
- **isort** - Python import sorter
- **pylint** - Python linter
- **clangd** - C/C++ language server
- **denols** - Deno runtime integration
- **gdtoolkit** - Godot linter/formatter
- **tectonic** - Self-contained LaTeX engine (no pdflatex/xelatex)
- **ImageMagick** (magick) - SVG icon pack rendering at `/opt/homebrew/bin/magick`
- **Google Gemini CLI** (gemini) - AI assistant via command-line (OAuth Pro mode, no API key)
- **JetBrainsMono Nerd Font** (Bold/ExtraBold) - Monospace font with icon glyphs
- **Tmux 3.x+** - Session management with status line and pane controls
- **Ghostty** - Terminal emulator with WebGPU rendering, graphics protocol support
## Configuration
- Configuration organized by tool in stow-ready structure:
- Dotfiles use GNU stow symlink structure (not committed)
- Top-level directories (`nvim/`, `ghostty/`, `tmux/`, etc.) are stow packages
- Stow links `*/.config/` → `~/.config/` and `*/.* → ~/.`
- **Neovim:** Lazy.nvim auto-clones from `https://github.com/folke/lazy.nvim.git` on first run
- **Tmux:** TPM auto-clones from `https://github.com/tmux-plugins/tpm` if missing
## Platform Requirements
- macOS (Arm64 / Apple Silicon or Intel)
- Homebrew for package installation (`/opt/homebrew/bin/` paths)
- Git (for plugin clone operations)
- Python 3.x
- Zsh as primary shell
- GPU support recommended (Ghostty WebGPU, real-icons.nvim graphics protocol)
- Terminal with true color (24-bit RGB) and italics support
- Kitty Graphics Protocol or Ghostty graphics for image rendering
- Quarto installed for notebook support
- Godot Engine running on port 6005 (for GDScript LSP)
- Timewarrior installed (for task time tracking integration)
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- Lua files use lowercase with hyphens: `options.lua`, `keymaps.lua`, `mini-icons.lua`
- Config files and directories follow XDG conventions: `.config/nvim/`, `.config/ghostty/`, `.tmux/`
- Plugin specs use descriptive lowercase names: `formatting.lua`, `codecompanion.lua`, `real-icons.lua`
- Snake_case for local functions: `update_q_for_empty_buffer()`, `critic_apply()`
- Keymaps use descriptive camelCase in descriptions: `"move down in buffer with cursor centered"`
- Module functions follow uppercase for module constants: `FocusGained`, `BufEnter`
- Local variables use snake_case: `lint_augroup`, `float_bg`, `editor_transparent`
- Global Vim settings use `vim.opt.*` or `vim.g.*` for proper scoping
- Configuration tables use uppercase for public values: `@thm_bg`, `@thm_red` (tmux theme colors)
- Lua tables for options use CamelCase keys mirroring Neovim API: `styles`, `formatters`, `linters_by_ft`
- Plugin spec tables follow lazy.nvim convention: `event`, `dependencies`, `config`, `keys`, `opts`
## Code Style
- Tool: `stylua` (Lua formatter)
- Indentation: 4 spaces (set in `conform.nvim`)
- Line length: No hard limit enforced, but code tends to stay under 100 chars for readability
- Tool: `luacheck` for Lua files (configured in `lua_ls` LSP)
- No global linting config file; validation done per-language in Neovim via `nvim-lint`
- Biome for JavaScript/TypeScript, Prettier for markdown/JSON/YAML
## Import Organization
- No explicit path aliases; uses relative Lua module paths under `lua/illico/`
- Plugins organized by category: `illico/plugins/`, `illico/plugins/lsp/`, `illico/core/`
- Lazy.nvim auto-discovers specs: `{ import = "illico.plugins" }` loads all files under that directory
## Error Handling
- Safe requires with `pcall()` for optional plugins:
- Autocmd safety: Check `vim.bo.buftype` and `vim.bo.modifiable` before operating on buffers (avoid E21 on special buffers):
- Silent keymap execution with `{ silent = true }` to prevent command echoing
- Silent LSP diagnostics updates with `update_in_insert = true` to avoid lag
## Logging
- Use `vim.notify()` for UI messages (not `print()` which prints to stdout)
- File path logging: `print("File path copied to clipboard: " .. filePath)` for status messages
- Comments inline document intent; no structured logging framework used (personal config)
## Comments
- Section separators using dashes: `-- ===== System clipboard =====` (visual organization)
- Intent explanations for non-obvious code: "Auto-reload files changed outside nvim"
- Disable explanations: "Disable netrw (we use mini.files for file exploration)"
- Spanish comments mixed with English — see "Language" below
- Inline single-line comments use `--` with single space: `-- Some comment`
- Block comments use visual separators:
- VSCode-style headings: `-- ===== Basics =====`, `-- ─────────────────────────`, `-- ── Section ──`
- Comments written in Spanish (neutral, latinoamericano):
- English used in keymap descriptions (`:desc` fields)
- Not used in this Lua-based config; Lua lacks standard documentation convention
- Function intent documented inline where needed
## Function Design
- Most functions stay under 30 lines
- Larger plugin configs break logic into setup blocks:
- Functions use descriptive parameter names: `function(pre, post)` for string wrapping
- Callbacks receive standard Neovim names: `callback = function()`, `pattern = "*"`
- No destructuring of complex tables; extract fields inline if needed
- Plugin specs return a table (lazy.nvim convention)
- Helper functions may return functions (closures for keymaps): `return function() ... end`
- Most functions operate on side effects (setting options, registering keymaps)
## Module Design
- Each plugin file returns a single lazy.nvim spec table:
- Core modules (`illico/core/*`) use `require()` pattern; no explicit exports
- `lua/illico/core/init.lua` imports all core submodules: `require("illico.core.options")`, etc.
- `lua/illico/plugins/init.lua` — not present; lazy.nvim imports via `{ import = "illico.plugins" }`
- Plugin specs are flat (no nesting); Lazy discovers them automatically
## Plugin Spec Convention
## Theming and Color Conventions
- Primary: Catppuccin Mocha (`catppuccin-mocha`)
- Transparent background enabled: `transparent_background = true` (lets terminal/tmux show through)
- Configured in `lua/illico/plugins/colorscheme.lua`
- Editor panes (`Normal`, `NormalNC`, `SignColumn`): 100% transparent (show desktop/terminal)
- Menus/Floats (`NormalFloat`, `Pmenu`, picker windows): Panel background `#181825` (Catppuccin mantle, opaque)
- Borders: Invisible (set to panel color to avoid visual clutter)
## Commit Message Conventions
- `nvim: menus sin borde y con fondo de panel opaco (todos los plugins)`
- `nvim: desactiva integracion mini_files de real-icons (congelaba <leader>e)`
- `nvim: instala real-icons.nvim (pack material) + picker unificado con transparencia`
- `nvim: elimina foldtext.lua (plugin spec ya no usado)`
- `nvim: narrow en pestaña nueva (pantalla completa) + tecla 'e' en aerial restaurada`
- Lowercase throughout (except proper nouns and acronyms like `LSP`, `PDF`)
- Lowercase after colons: `nvim: menus...` not `nvim: Menus...`
- Detail rationale in parentheses for clarity: `(congelaba <leader>e)`
- Use imperative mood when applicable: `instala`, `desactiva`, `elimina`, `arranca`
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## System Overview
```text
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
- Each tool is a standalone package with its own XDG directory tree
- Symlinks deployed from repo to `$HOME` using stow (or equivalent manual symlinking)
- Configs are source-able/loadable (e.g., zsh aliases sourced from hooks scripts)
- Cross-tool integration: Nvim + Tmux, Ghostty + Tmux, Taskwarrior hooks + Nvim plugin
- Lua as primary config language for Nvim; Bash/Zsh for scripts and aliases
- Custom hooks and scripts add functionality (Taskwarrior hooks, Tmux scripts, Ghostty shaders)
## Layers
- Purpose: Bootstrap and initialize tool startup
- Location: Tool-specific entry points (`init.lua`, `.tmux.conf`, `config`, `.taskrc`, shell rc files)
- Contains: Core settings, bootstrap logic, plugin initialization
- Depends on: Runtime (Lua VM, shell, terminal)
- Used by: Operating system / shell
- Purpose: Define keymaps, options, theme, and behavior
- Location: `nvim/lua/illico/core/`, `tmux/.tmux.conf`, `ghostty/.config/ghostty/`
- Contains: Keymaps, editor options, terminal colors, window behavior
- Depends on: Tool runtime libraries
- Used by: Entry point layer
- Purpose: Load and configure third-party plugins
- Location: `nvim/lua/illico/plugins/`, `nvim/.config/nvim/lua/illico/lazy.lua`
- Contains: Plugin specs, plugin-specific configs, LSP configs
- Depends on: Lazy.nvim package manager, core configs
- Used by: Init.lua after core loads
- Purpose: Connect tools (Nvim ↔ Tmux, Taskwarrior ↔ Nvim, Ghostty ↔ Tmux)
- Location: Taskwarrior hooks (`taskwarrior/.task/hooks/`), Nvim plugins, Shell aliases
- Contains: Cross-tool scripts, hooks, custom functions
- Depends on: All underlying tools
- Used by: Event triggers (task on-add, on-modify; shell aliases)
- Purpose: Shared scripts, functions, and data processing
- Location: `taskwarrior/.task/hooks/`, `nvim/lua/illico/`, Tmux scripts
- Contains: Post-processors, colorizers, formatters, custom Lua modules
- Depends on: Core tool APIs
- Used by: Config layer and hooks
## Data Flow
### Nvim Startup Sequence
### Taskwarrior Task Execution & Post-Processing
### Ghostty Terminal Launch
### Tmux ↔ Nvim Integration
### Shell Startup (zsh)
## Key Abstractions
- Purpose: Organize configs by tool, deploy to home via symlinks
- Examples: `nvim/`, `tmux/`, `ghostty/`, `taskwarrior/`, `claude/`
- Pattern: Each package contains a shadow of `$HOME` file tree (e.g., `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`)
- Purpose: Organize Nvim configs in Lua modules, avoid global namespace pollution
- Examples: `illico.core.*`, `illico.plugins.*`, `illico.plugins.lsp.*`
- Pattern: Require statements build dependency graph; lazy.nvim resolves
- Purpose: Declare plugin source, dependencies, config, and load conditions
- Examples: `lsp/lspconfig.lua` specs mason + lspconfig + handlers
- Pattern: Each file is a table or function returning tables; lazy.nvim reads and installs
- Purpose: Intercept task events (add, modify) and post-process output
- Examples: `on-add.effort`, `colorize-top`, `link-icon`
- Pattern: Hooks are executables in `~/.task/hooks/`; referenced in `.taskrc` as `hooks.location`
- Purpose: Extend CLI tools with custom logic (preprocessing, post-processing)
- Examples: `task()` in zsh, `ccommit()` in zsh
- Pattern: Wrapper uses `command <tool>` to avoid recursion, pipes and processes output
## Entry Points
- Location: `nvim/.config/nvim/init.lua`
- Triggers: `nvim <file>` or `nvim` (opens editor)
- Responsibilities:
- Location: `tmux/.tmux.conf`
- Triggers: `tmux new-session` (auto-launched by Ghostty)
- Responsibilities:
- Location: `ghostty/.config/ghostty/config`
- Triggers: Ghostty app launch
- Responsibilities:
- Location: `taskwarrior/.taskrc`
- Triggers: `task <command>` (via shell wrapper)
- Responsibilities:
- Location: `claude/.claude/CLAUDE.md`
- Triggers: Manual source or symlink in Claude desktop app config
- Responsibilities:
- Location: Shell RC files (user's `~/.zshrc`)
- Triggers: Shell startup
- Responsibilities:
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
### Hardcoded Absolute Paths in Scripts
### Plugin Configs Modifying Global Vim State Without Isolation
### Taskwarrior Hook Scripts Assuming Unix Tools Availability
## Error Handling
- **Nvim lazy.nvim:** If plugin clone fails, lazy.nvim shows error message and continues (plugins with install errors marked in UI)
- **Taskwarrior hooks:** If hook returns non-zero, task operation is aborted with error message; user must fix hook
- **Shell wrappers:** Use `|| { print -u2 "error"; return 1 }` to report and exit early
- **Tmux terminal capabilities:** Fallback from tmux-256color to screen-256color if terminfo missing; truecolor restored via terminal-overrides
## Cross-Cutting Concerns
- Nvim: Uses `vim.notify()` (redirected to snacks.notifier) for user-visible messages
- Taskwarrior: Outputs to stdout/stderr in hooks; errors shown in task CLI output
- Shell: Uses `print` (zsh) with `-u2` for stderr, color ANSI codes for terminal output
- Nvim: Plugin specs validated by lazy.nvim at startup; malformed specs fail early
- Taskwarrior: Hook scripts responsible for validation; `.taskrc` validated by taskwarrior CLI on read
- Shell: No runtime validation; user responsible for correct syntax in `.zshrc` / hook scripts
- Claude CLI: Reads API key from env (likely `CLAUDE_API_KEY` or `~/.claude/credentials`); managed externally (not in this repo per `.gitignore`)
- Taskwarrior: No auth (local database); git integration (`task-git.sh` hook) authenticates via SSH key or token
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
