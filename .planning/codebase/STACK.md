# Technology Stack

**Analysis Date:** 2026-06-25

## Languages

**Primary:**
- Lua - Neovim configuration and plugins (`nvim/.config/nvim/lua/`)
- Shell (Bash, Zsh) - Tmux scripts, task hooks, shell configuration

**Secondary:**
- GLSL - Custom shader programs for Ghostty terminal (`ghostty/.config/ghostty/shaders/`)
- Swift - macOS integration utilities (`tmux/.tmux/scripts/qpreview.swift`)
- Python - Data processing and utilities (taskwarrior hooks use Python 3)

## Runtime

**Environment:**
- Neovim 0.11+ (recent treesitter integration, LSP features)
- Lua 5.1+ (embedded in Neovim)
- Zsh (primary shell)
- Bash 3.2+ (macOS system bash)
- Python 3.x (via `/opt/homebrew/bin/python3`)

**Package Manager:**
- **Neovim plugins:** lazy.nvim (bootstrap at `nvim/.config/nvim/lua/illico/lazy.lua`)
- **Tmux plugins:** tpm (Tmux Plugin Manager, bootstraps from `~/.tmux/plugins/tpm`)
- **Taskwarrior:** Built-in hook system (Python-based)

## Frameworks

**Core:**
- **Neovim LSP** - Language Server Protocol for code intelligence
  - Client: nvim-lspconfig (multiple LSP servers)
  - Auto-installation: mason.nvim + mason-lspconfig.nvim + mason-tool-installer.nvim

**UI/Editor:**
- **lazy.nvim** - Plugin manager for Neovim
- **Snacks.nvim** - Utility framework (notifications, pickers, window management)
- **Noice.nvim** - Enhanced command/notification UI
- **Which-key.nvim** - Keybinding help menu
- **Telescope.nvim** - Fuzzy finder and picker

**Editing:**
- **Conform.nvim** - Code formatter wrapper (Prettier, Stylua, isort)
- **Nvim-lint** - Asynchronous linter integration
- **nvim-cmp** - Autocompletion engine with multiple sources

**Themes/Visual:**
- **Catppuccin/nvim** - Color scheme (Mocha flavor)
- **Real-icons.nvim** - Graphics protocol icon rendering (Ghostty backend)
- **Mini.* modules** - UI components (files, icons, splitjoin, surround, animate)
- **Lualine.nvim** - Statusline with buffer tabs

**Language Support:**
- **Treesitter** (nvim-treesitter) - AST parsing and syntax highlighting
- **Quarto-nvim** - Quarto document support (R/Python notebooks)
- **VimTeX** - LaTeX editing (via Tectonic engine)
- **Orgmode** - Org-mode support
- **Neorg** - Knowledge base system (with captures and templates)

**Writing/Notebook:**
- **Image.nvim** - Image rendering in editor
- **Img-clip.nvim** - Screenshot/clipboard image handling
- **Markdown-preview.nvim** - Markdown preview in browser
- **Render-markdown.nvim** - Markdown rendering in editor

**Navigation:**
- **Aerial.nvim** - Code outline sidebar
- **Leap.nvim** - Lightweight motion plugin (Codeberg source: https://codeberg.org/andyg/leap.nvim)
- **Focus.nvim** - Automatic window focusing
- **Vim-maximizer** - Window maximize/minimize
- **Mini.files** - File explorer

**Git Integration:**
- **Gitsigns.nvim** - Git diff signs and hunks
- **Lazygit.nvim** - Lazygit terminal UI integration

**Terminal & Session:**
- **Tmux** - Terminal multiplexer with custom configuration
- **Ghostty** - Modern GPU-accelerated terminal emulator

**Godot Game Engine:**
- **GDScript LSP** - Direct TCP connection to Godot Editor (port 6005)
- **GDShader Language Server** (gdshader-language-server)

## Key Dependencies

**Critical Infrastructure:**
- **Mason.nvim** - Unified package manager for LSP servers and tools
  - Installs: lua_ls, ts_ls, html, cssls, tailwindcss, angularls, emmet_ls, marksman, pyright, clangd, denols, gdtoolkit
- **Lazy.nvim** - 80+ plugins managed via lazy-loading spec

**External Tools (installed via Mason or Homebrew):**
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

**Fonts:**
- **JetBrainsMono Nerd Font** (Bold/ExtraBold) - Monospace font with icon glyphs

**Terminal/Multiplexer:**
- **Tmux 3.x+** - Session management with status line and pane controls
- **Ghostty** - Terminal emulator with WebGPU rendering, graphics protocol support

## Configuration

**Environment:**
- Configuration organized by tool in stow-ready structure:
  - `nvim/.config/nvim/` - Neovim configuration (init.lua + Lua modules)
  - `ghostty/.config/ghostty/` - Ghostty terminal config + shaders
  - `tmux/.tmux.conf` - Tmux configuration
  - `taskwarrior/.task/` - Taskwarrior database + hooks
  - `taskwarrior/.taskrc` - Taskwarrior config
  - `claude/.claude/` - Claude AI agent configuration
  - `claude/.config/zsh/` - Zsh configuration snippets

**Deployment via Stow:**
- Dotfiles use GNU stow symlink structure (not committed)
- Top-level directories (`nvim/`, `ghostty/`, `tmux/`, etc.) are stow packages
- Stow links `*/.config/` → `~/.config/` and `*/.* → ~/.`

**Build/Bootstrap:**
- **Neovim:** Lazy.nvim auto-clones from `https://github.com/folke/lazy.nvim.git` on first run
- **Tmux:** TPM auto-clones from `https://github.com/tmux-plugins/tpm` if missing

## Platform Requirements

**Development:**
- macOS (Arm64 / Apple Silicon or Intel)
- Homebrew for package installation (`/opt/homebrew/bin/` paths)
- Git (for plugin clone operations)
- Python 3.x
- Zsh as primary shell

**Runtime:**
- GPU support recommended (Ghostty WebGPU, real-icons.nvim graphics protocol)
- Terminal with true color (24-bit RGB) and italics support
- Kitty Graphics Protocol or Ghostty graphics for image rendering

**Optional:**
- Quarto installed for notebook support
- Godot Engine running on port 6005 (for GDScript LSP)
- Timewarrior installed (for task time tracking integration)

---

*Stack analysis: 2026-06-25*
