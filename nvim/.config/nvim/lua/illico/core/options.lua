


-- illico/core/options.lua

-- 🟢 FIX: Disable netrw at the very start to prevent flickering when opening Neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ===== Basics =====
-- Configuración del cursor:
-- n-v-c-sm:block  -> Bloque en modos Normal, Visual, Comando
-- i-ci-ve:ver25   -> Barra vertical fina en modo Insertar
-- r-cr-o:hor20    -> Subrayado en modo Reemplazo
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
vim.opt.wrap = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- ===== System clipboard =====
vim.opt.clipboard = "unnamedplus"

-- Where Neovim stores views (you can keep default; this just ensures it exists)
vim.opt.viewdir = vim.fn.stdpath("state") .. "/view"
vim.fn.mkdir(vim.opt.viewdir:get(), "p")

-- Save/load folds (and cursor, etc.) in views
vim.opt.viewoptions = { "cursor", "folds" }

vim.o.wildmenu = false
vim.o.wildoptions = "" -- IMPORTANT: removes the built-in popupmenu behavior

-- Transparency: Clear background for main window and floating windows
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })-- Save/load folds (and cursor, etc.) in views
vim.opt.viewoptions = { "cursor", "folds" }

vim.o.wildmenu = false
vim.o.wildoptions = "" -- IMPORTANT: removes the built-in popupmenu behavior

-- Transparency: Clear background for main window and floating windows
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
