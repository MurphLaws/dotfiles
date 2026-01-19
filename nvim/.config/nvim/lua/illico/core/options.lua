-- illico/core/options.lua

-- 🟢 FIX: Disable netrw at the very start to prevent flickering when opening Neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ===== Basics =====
-- Configuración del cursor:
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.cursorline = true -- Resalta la línea donde está el cursor

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.updatetime = 200
vim.opt.timeoutlen = 300

-- Wrapping global desactivado (ideal para código)
-- Se activa localmente en orgmode/markdown según sea necesario
vim.opt.wrap = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- ===== System clipboard =====
vim.opt.clipboard = "unnamedplus"

-- ===== Movimiento Visual (Better Wrapping Navigation) =====
-- Esto permite que j y k se muevan por líneas visuales cuando hay wrapping (wrap=true),
-- pero se comporta normalmente cuando no hay wrapping.
vim.keymap.set("n", "j", "gj", { silent = true })
vim.keymap.set("n", "k", "gk", { silent = true })

-- ===== Views & Session =====
-- Where Neovim stores views
vim.opt.viewdir = vim.fn.stdpath("state") .. "/view"
vim.fn.mkdir(vim.opt.viewdir:get(), "p")

-- Save/load folds (and cursor, etc.) in views
vim.opt.viewoptions = { "cursor", "folds" }

-- ===== UI Noise Reduction =====
vim.o.wildmenu = false
vim.o.wildoptions = "" -- IMPORTANT: removes the built-in popupmenu behavior

-- ===== Transparency =====
-- Clear background for main window and floating windows
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
