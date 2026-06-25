# External Integrations

**Analysis Date:** 2026-06-25

## APIs & External Services

**AI Assistance:**
- **Google Gemini** - AI code and writing assistance
  - SDK/Client: `gemini` CLI (https://github.com/google/generative-ai-cli)
  - Auth: OAuth Pro mode (no API key required, no free-tier limits)
  - Implementation: `nvim/.config/nvim/lua/illico/plugins/codecompanion.lua` shells out to `gemini -p ...`
  - Models: gemini-2.5-flash (default), gemini-2.5-pro (toggle via `<leader>iM`)
  - Usage: Inline assistant, commit message generation, chat mode via CodeCompanion adapter

**Game Engine Integration:**
- **Godot Engine** - Game development IDE
  - Connection: Direct TCP socket on 127.0.0.1:6005
  - LSP: GDScript language server (built into Godot)
  - Implementation: `nvim/.config/nvim/lua/illico/plugins/lsp/lspconfig.lua` lines 74-77

## Plugin & Package Registries

**Neovim Plugins (GitHub):**
- **lazy.nvim** - Plugin manager auto-bootstraps from:
  - Repository: `https://github.com/folke/lazy.nvim`
  - Branch: stable
  - Bootstrap location: `nvim/.config/nvim/lua/illico/lazy.lua` (lines 2-15)
  
**80+ Plugins installed via lazy.nvim:**
- Core plugins from GitHub:
  - `folke/*` (noice.nvim, lazy.nvim, zen-mode.nvim)
  - `neovim/nvim-lspconfig`
  - `hrsh7th/*` (nvim-cmp, autocompletion ecosystem)
  - `williamboman/*` (mason, mason-lspconfig, mason-tool-installer)
  - `catppuccin/nvim` (colorscheme)
  - `nvim-telescope/*` (fuzzy finder)
  - `nvim-treesitter/*` (syntax parsing)
  - `echasnovski/mini.*` (mini.files, mini.icons, mini.surround, etc.)
  
- Full dependency tree in: `nvim/.config/nvim/lazy-lock.json` (83 plugins locked to specific commits)

**Tmux Plugins (GitHub):**
- **tpm** (Tmux Plugin Manager) - Auto-bootstraps from:
  - Repository: `https://github.com/tmux-plugins/tpm`
  - Bootstrap location: `tmux/.tmux.conf` lines 184-186
  
- Plugins installed via tpm:
  - `tmux-plugins/tpm` - Plugin manager itself
  - `tmux-plugins/tmux-online-status` - Network connectivity indicator

**Language Servers & Tools (via Mason):**
- Installed through mason package registry:
  - LSP Servers: lua_ls, ts_ls, html, cssls, tailwindcss, angularls, emmet_ls, marksman, pyright
  - Formatters: prettier, stylua, isort
  - Linters: pylint, eslint_d
  - Tools: clangd, denols, gdtoolkit

## Data Storage

**Taskwarrior Database:**
- **Location:** `~/.task/` (configuration-managed at `taskwarrior/.task/`)
- **Format:** Custom task database with JSON export capability
- **Version:** taskwarrior 3.4.2+
- **Configuration file:** `taskwarrior/.taskrc`
- **UDAs (User Defined Attributes):**
  - `note` (date) - Annotation timestamp
  - `link` (string) - URL or file path for tasks
  - `effort` (string) - 0.1-20 (effort level for urgency calculation)
  - `effort_urg` (string) - Computed urgency contribution from effort

**Git Integration:**
- **Hook-based:** taskwarrior tasks sync to git via `taskwarrior/.task/hooks/task-git.sh`
- **Storage:** Task data stored in Git commits (version control for task history)

## Caching & Sessions

**Neovim:**
- **Undo history:** `$XDG_STATE_HOME/nvim/undodir/` (persistent undo trees)
- **Views (folds/cursor):** `$XDG_STATE_HOME/nvim/view/` (per-file views)
- **Mason package cache:** `$XDG_DATA_HOME/nvim/mason/` (installed LSP servers, tools)

**Tmux:**
- **Session persistence:** Managed in-memory (no persistent session store)
- **Status variables:** Custom hooks for @claude_done notification flag (inter-window state)

**Ghostty:**
- **History:** Scrollback buffer (ephemeral, not persisted between sessions)
- **Window state:** Not persisted between launches

## Authentication & Identity

**Auth Provider:**
- **Google OAuth** (Gemini CLI) - OAuth 2.0 via browser-based flow
  - No API keys stored (trust-based auth)
  - Usage: `gemini --skip-trust` (user pre-authenticated)

**Git Identity:**
- **User configuration:** Managed at system level (`git config user.name`, `git config user.email`)
- **SSH keys:** System-managed (not in dotfiles, respects `~/.ssh/`)

## Monitoring & Observability

**Error Tracking:**
- Not detected - Errors logged to Neovim's `:messages` buffer and Tmux status line

**Logs:**
- **Neovim:** vim.notify() → Snacks.nvim notification panel
- **Tmux:** Pane border status indicators (zoom state, session name)
- **Taskwarrior:** Hooks log to task database and annotations

**Window Notifications (Tmux-specific):**
- @claude_done flag displayed in window status (`tmux/.tmux.conf` line 127-143)
- Manually cleared when window is selected (`after-select-window` hook)

## CI/CD & Deployment

**Hosting:**
- Local machine only (personal dotfiles repository)
- GitHub remote repository (public, no secrets)

**CI Pipeline:**
- Not detected - Repository is configuration-driven, not application code

**Build/Installation:**
- Manual via `stow` command (creates symlinks from dotfiles to `~/.config/`, `~/` directories)
- Neovim plugins auto-installed via lazy.nvim bootstrap
- Tmux plugins auto-installed via tpm bootstrap

## Version Control

**Repository:**
- GitHub (public fork/clone, tracked in git)
- Branches: main (development)
- Commit tracking: User history visible in `.git/` directory
- `.gitignore`: `.DS_Store`, `__pycache__/`

## Environment Configuration

**Required env vars:**
- `HOME` - User home directory
- `TERM` - Terminal type (set to "screen-256color" in Tmux for compatibility)
- `PATH` - Includes `/opt/homebrew/bin` for Homebrew tools
- `VIMRUNTIME` - Neovim runtime path (auto-set by Neovim)

**Optional env vars:**
- `TERM_PROGRAM` - Terminal identifier (updated in Tmux via `allow-passthrough`)
- `QUARTO_BIN` - Quarto executable path (if quarto-nvim used)
- `GOOGLE_AUTH_TOKEN` - Gemini CLI auth (stored by Google OAuth flow, not in dotfiles)

**Secrets location:**
- **No secrets in repository** - Public dotfiles, no .env files
- Google Gemini auth managed by `gemini` CLI (system keychain/auth store)
- SSH keys: System `~/.ssh/` (not in dotfiles)

## Fonts & Theme Sources

**Fonts:**
- **JetBrainsMono Nerd Font** Mono (Bold + ExtraBold variants)
  - Source: Homebrew or JetBrains download
  - Used by: Ghostty terminal (`ghostty/.config/ghostty/config` line 2)
  - Icon support: Nerd Font glyph extensions for Neovim UI

**Themes:**
- **Catppuccin Mocha** - Color scheme
  - Repository: `catppuccin/nvim` (GitHub)
  - Colors defined in: `nvim/.config/nvim/lua/illico/plugins/colorscheme.lua`
  - Also used in: `tmux/.tmux.conf` (lines 66-87), `ghostty/.config/ghostty/config` (lines 17-33)

**Icons:**
- **Real-icons.nvim** - Graphics protocol icons
  - Pack: Material design icon pack
  - Backend: Ghostty graphics protocol
  - Fallback: Mini.icons (Nerd Font glyphs)
  - Build command: `:RealIconsInstallPack material`

**Shaders (Ghostty):**
- **Custom GLSL shaders** at `ghostty/.config/ghostty/shaders/`:
  - `retro-crt.glsl` - Retro CRT scanlines + bloom + vignette (preserves Catppuccin colors)
  - `cursor-smear.glsl` - Cursor smear animation (Neovide-style)
  - Both loaded and animated via `custom-shader` + `custom-shader-animation` in ghostty config

## Webhooks & Callbacks

**Incoming:**
- Taskwarrior hooks (executed on task events):
  - `on-add.effort` - Adds effort UDA on new tasks
  - `on-modify.effort` - Updates effort urgency coefficient
  - `on-modify.timewarrior` - Syncs with Timewarrior time tracking

**Outgoing:**
- **Task Git sync** (`taskwarrior/.task/hooks/task-git.sh`):
  - Commits task changes to git after task modifications
  - Implements task-to-git bidirectional sync
  
- **Tmux lifecycle hooks** (`tmux/.tmux.conf`):
  - `after-select-window` - Runs QuartoSplit window resize script + clears @claude_done flag
  - `after-new-window` - Runs QuartoSplit window resize script on new window

**Quarto Notebook Integration:**
- Tmux executes shell script `tmux/.tmux/scripts/quarto-tile.sh`:
  - Splits Ghostty terminal (left half) + WebKit preview pane (right half)
  - Triggered on window selection/creation for notebook editing workflows

## Language Server Protocol (LSP)

**Configured Servers** (via `nvim/.config/nvim/lua/illico/plugins/lsp/lspconfig.lua`):

| Language | Server | Source | Purpose |
|----------|--------|--------|---------|
| Lua | lua_ls | Mason | Neovim config/plugin LSP |
| TypeScript | ts_ls | Mason | Node.js/web development |
| HTML | html | Mason | Web markup |
| CSS | cssls | Mason | Web styling |
| Tailwind CSS | tailwindcss | Mason | Utility CSS framework |
| Angular | angularls | Mason | Angular framework |
| JavaScript/JSON | emmet_ls | Mason | Template expansion |
| Markdown | marksman | Mason | Markdown linting |
| Python | pyright | Mason | Notebook code cells + scripts |
| C/C++ | clangd | Mason | Systems programming |
| Deno | denols | Mason | Deno runtime JavaScript/TypeScript |
| Godot GDScript | gdscript | Godot Editor | Game engine scripting (TCP port 6005) |
| Godot GDShader | gdshader | External LSP | Game engine shaders |

## Command-Line Tools Integration

**Gemini CLI:**
- Invoked by: `nvim/.config/nvim/lua/illico/plugins/codecompanion.lua`
- Command: `gemini -p <prompt> -m <model> -o text`
- Models: gemini-2.5-flash, gemini-2.5-pro (toggle-able)
- Output: Parsed ANSI-stripped text, displayed in side panel

**Tectonic (LaTeX):**
- Invoked by: `nvim/.config/nvim/lua/illico/plugins/vimtex.lua`
- Self-contained LaTeX engine (no pdflatex, xelatex, or biber required)
- Downloads packages on-demand
- Compilation command: `<leader>ll` in .tex files

**ImageMagick (magick):**
- Used by: `real-icons.nvim` for SVG icon pack rendering
- Location: `/opt/homebrew/bin/magick`
- Purpose: Rasterize Material Design SVG icons to images

**Python 3:**
- Used by: Taskwarrior hooks, notebook code execution
- Location: `/opt/homebrew/bin/python3`
- Hooks: `on-add.effort`, `on-modify.effort`, `on-modify.timewarrior`

---

*Integration audit: 2026-06-25*
