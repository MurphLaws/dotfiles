# dotfiles

Configuración personal para macOS, desplegada con [GNU Stow](https://www.gnu.org/software/stow/).
Cada carpeta de primer nivel es un paquete stow (refleja el árbol de `$HOME`).

## Herramientas

- [Homebrew](https://brew.sh) — gestor de paquetes
- [GNU Stow](https://www.gnu.org/software/stow/) — symlinks de dotfiles
- [Neovim](https://neovim.io) + [lazy.nvim](https://github.com/folke/lazy.nvim) — editor y gestor de plugins
- [Ghostty](https://ghostty.org) — terminal
- [tmux](https://github.com/tmux/tmux) + [tpm](https://github.com/tmux-plugins/tpm) — multiplexor
- [Zsh](https://www.zsh.org) + [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) — shell y prompt
- [Taskwarrior](https://taskwarrior.org) + [Timewarrior](https://timewarrior.net) — tareas y tiempo

## Paquetes (stow)

| Paquete | Contiene |
|---------|----------|
| `nvim` | Config de Neovim (`~/.config/nvim`) |
| `ghostty` | Config y shaders de Ghostty (`~/.config/ghostty`) |
| `tmux` | `~/.tmux.conf` y scripts |
| `zsh` | `~/.zshrc`, `~/.p10k.zsh`, `~/.zprofile`, `~/.zshenv` |
| `taskwarrior` | `~/.taskrc`, hooks y aliases |
| `timewarrior` | `~/.config/timewarrior` |
| `claude` | Config de Claude Code (`~/.claude`: CLAUDE.md, settings.json, skills, hooks) |
| `zellij` | `~/.config/zellij` |
| `htop` | `~/.config/htop` |
| `fish` | `~/.config/fish` |
| `mpv` | `~/.config/mpv` (yt-dlp con impersonación para zigoku) |
| `git` | `~/.config/git/ignore` (gitignore global) |
| `spotify-player` | `~/.config/spotify-player` (keymap + `app.toml.example`) |
| `myx` | `~/.config/myx` (`client_id.example`) |
| `graphview` | CLI graph view tipo Obsidian (`~/.local/bin/graphview`) |

Directorios que **no** son paquetes stow: `forks/` (parches de binarios TUI, ver abajo),
`games/` (código fuente y saves de juegos de terminal), `voyager-keycaps/` (STLs del
teclado), `Brewfile`.

## Restaurar en un Mac nuevo

```sh
# 1. Homebrew + todos los paquetes (formulae, casks, taps)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/MurphLaws/dotfiles ~/dotfiles && cd ~/dotfiles
brew bundle --file=Brewfile

# 2. Shell: Oh My Zsh + Powerlevel10k
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH:-$HOME/.oh-my-zsh}/custom/themes/powerlevel10k"
rm -f ~/.zshrc   # el install de omz crea uno; lo reemplaza el stow

# 3. Enlazar toda la config
stow nvim ghostty tmux zsh taskwarrior timewarrior claude zellij htop fish mpv git spotify-player myx graphview

# 4. tmux: gestor de plugins (luego prefix+I dentro de tmux)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 5. Secretos (NO están en el repo)
cp ~/dotfiles/zsh/.config/zsh/conf.d/secrets.zsh.example ~/.config/zsh/conf.d/secrets.zsh
$EDITOR ~/.config/zsh/conf.d/secrets.zsh   # pega tus API keys reales
# Spotify (client_id de tu app en developer.spotify.com):
cp ~/.config/myx/client_id.example ~/.config/myx/client_id
cp ~/.config/spotify-player/app.toml.example ~/.config/spotify-player/app.toml
$EDITOR ~/.config/myx/client_id ~/.config/spotify-player/app.toml

# 6. Neovim: abre nvim y lazy.nvim instala todo solo
nvim --headless "+Lazy! sync" +qa
```

> Las API keys viven solo en `~/.config/zsh/conf.d/secrets.zsh` (gitignored).
> La plantilla con los nombres de cada variable está en `zsh/.config/zsh/conf.d/secrets.zsh.example`.

### Claude Code — copiar el estado del Mac viejo

Lo versionado (CLAUDE.md, settings.json, skills, hooks) llega solo con `stow claude`.
El estado que NO va al repo (memoria por proyecto, historial, plugins, settings.local.json)
se copia directo del Mac viejo. En el **Mac viejo**:

```sh
rsync -av --exclude 'cache' --exclude 'shell-snapshots' --exclude 'debug' \
      --exclude 'file-history' --exclude 'daemon*' --exclude 'telemetry' \
      ~/.claude/projects ~/.claude/plugins ~/.claude/settings.local.json \
      ~/.claude/history.jsonl \
      nuevo-mac:~/.claude/
```

(o el equivalente con AirDrop / disco externo: lo importante son `~/.claude/projects/`
— ahí vive la memoria persistente — `plugins/` y `settings.local.json`).
Los agentes `gsd-*` en `~/.claude/agents` los instala GSD (get-shit-done), no el repo.

### Forks TUI parcheados (`forks/`)

Binarios de `~/.local/bin` que son forks locales con parches propios. Los parches
están en `forks/<proyecto>/`:

**myx** (Spotify TUI, cover grande + queue strip):

```sh
git clone https://github.com/HaseebKhalid1507/Myx ~/.local/src/myx && cd ~/.local/src/myx
git checkout 25fdc5d   # base de los parches (v0.2.5)
git am ~/dotfiles/forks/myx/*.patch
cargo build --release && cp target/release/myx ~/.local/bin/
```

**spotify_player** (smart shuffle):

```sh
git clone https://github.com/aome510/spotify-player ~/.local/src/spotify-player && cd ~/.local/src/spotify-player
git checkout 9b81aaa   # base del parche (v0.24.0)
git apply ~/dotfiles/forks/spotify-player/smart-shuffle.patch
cargo build --release && cp target/release/spotify_player ~/.local/bin/
```

`~/.local/bin` va antes que homebrew en el PATH (lo configura el `.zshrc`), así los
binarios parcheados shadowan a los de brew.

## Plugins de Neovim

- [image.nvim](https://github.com/3rd/image.nvim)
- [org-bullets.nvim](https://github.com/akinsho/org-bullets.nvim)
- [neorg-better-captures](https://github.com/andreadev-it/neorg-better-captures)
- [telescope-themes](https://github.com/andrew-george/telescope-themes)
- [nvim-lsp-file-operations](https://github.com/antosha417/nvim-lsp-file-operations)
- [incline.nvim](https://github.com/b0o/incline.nvim)
- [lualine-pretty-path](https://github.com/bwpge/lualine-pretty-path)
- [focus.nvim](https://github.com/casedami/focus.nvim)
- [catppuccin/nvim](https://github.com/catppuccin/nvim)
- [mini.animate](https://github.com/echasnovski/mini.animate)
- [mini.icons](https://github.com/echasnovski/mini.icons)
- [mini.splitjoin](https://github.com/echasnovski/mini.splitjoin)
- [mini.surround](https://github.com/echasnovski/mini.surround)
- [mini.trailspace](https://github.com/echasnovski/mini.trailspace)
- [cmp-spell](https://github.com/f3fora/cmp-spell)
- [lazydev.nvim](https://github.com/folke/lazydev.nvim)
- [noice.nvim](https://github.com/folke/noice.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)
- [trouble.nvim](https://github.com/folke/trouble.nvim)
- [which-key.nvim](https://github.com/folke/which-key.nvim)
- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim)
- [wilder.nvim](https://github.com/gelguy/wilder.nvim)
- [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim)
- [cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline)
- [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
- [cmp-path](https://github.com/hrsh7th/cmp-path)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [otter.nvim](https://github.com/jmbuhr/otter.nvim)
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [tunnelvision.nvim](https://github.com/leolaurindo/tunnelvision.nvim)
- [vimtex](https://github.com/lervag/vimtex)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [modicator.nvim](https://github.com/mawkler/modicator.nvim)
- [undotree](https://github.com/mbbill/undotree)
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
- [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- [real-icons.nvim](https://github.com/Mirsmog/real-icons.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [modes.nvim](https://github.com/mvllow/modes.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [mini.files](https://github.com/nvim-mini/mini.files)
- [neorg](https://github.com/nvim-neorg/neorg)
- [orgmode](https://github.com/nvim-orgmode/orgmode)
- [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [showkeys](https://github.com/nvzone/showkeys)
- [typr](https://github.com/nvzone/typr)
- [volt](https://github.com/nvzone/volt)
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)
- [lspkind.nvim](https://github.com/onsails/lspkind.nvim)
- [neorg-capture](https://github.com/pritchett/neorg-capture)
- [neorg-templates](https://github.com/pysan3/neorg-templates)
- [quarto-nvim](https://github.com/quarto-dev/quarto-nvim)
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- [nvim-notify](https://github.com/rcarriga/nvim-notify)
- [fzy-lua-native](https://github.com/romgrk/fzy-lua-native)
- [tailwindcss-colorizer-cmp.nvim](https://github.com/roobert/tailwindcss-colorizer-cmp.nvim)
- [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [blink.cmp](https://github.com/saghen/blink.cmp)
- [nvim-navic](https://github.com/SmiteshP/nvim-navic)
- [aerial.nvim](https://github.com/stevearc/aerial.nvim)
- [conform.nvim](https://github.com/stevearc/conform.nvim)
- [vim-maximizer](https://github.com/szw/vim-maximizer)
- [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
- [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
- [mason.nvim](https://github.com/williamboman/mason.nvim)
- [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)
- [leap.nvim](https://codeberg.org/andyg/leap.nvim)
