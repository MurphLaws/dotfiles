# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup note

This repo no longer includes a bootstrap installer script. Setup is manual via
Stow/Brewfile.

## Brew packages

ada-url, brotli, c-ares, ca-certificates, fmt, fzf, gettext, hdrhistogram_c, icu4c, json-c, libevent, libffi, libnghttp2, libnghttp3, libngtcp2, libunistring, libuv, llhttp, lpeg, luajit, luv, lz4, merve, nbytes, ncurses, neovim, node, openssl, pcre2, readline, ripgrep, simdjson, simdutf, sqlite, stow, task, tmux, tree, tree-sitter, unibilium, utf8proc, uvwasi, xz, zstd

**Casks:** codex, copilot-cli

## macOS defaults

Preferences that live outside this repo (in `~/Library/Preferences`, so Stow
does not manage them). Re-apply them on a fresh machine:

### Ghostty: press-and-hold accent menu (ñ, á, é, …)

Ghostty (like most terminals) disables the macOS press-and-hold accent picker so
keys auto-repeat. Enable it so holding a key (e.g. `n`) shows the accent menu —
useful for typing Spanish:

```bash
defaults write com.mitchellh.ghostty ApplePressAndHoldEnabled -bool true
```

Then fully quit and reopen Ghostty (Cmd+Q). Tradeoff: held keys no longer
auto-repeat *in Ghostty*. Revert with:

```bash
defaults delete com.mitchellh.ghostty ApplePressAndHoldEnabled
```

## Neovim plugins

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
- [nabla.nvim](https://github.com/jbyuki/nabla.nvim)
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
