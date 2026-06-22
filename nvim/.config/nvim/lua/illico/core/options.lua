-- illico/core/options.lua

-- Disable netrw (we use mini.files for file exploration)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Desactivar providers que no se usan (solo usamos python3).
-- Silencia los warnings de :checkhealth por neovim npm / perl / ruby gem.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

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

-- Auto-reload files changed outside nvim (e.g. Godot editor writing to .gd files).
-- Without this, saving triggers "WARNING: The file has been changed since reading it!!!"
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})

-- When checktime detects an external change, reload silently instead of prompting.
-- This is what actually suppresses the W11/W12 "do you want to save?" dialog.
vim.api.nvim_create_autocmd("FileChangedShell", {
	pattern = "*",
	callback = function()
		vim.v.fcs_choice = "reload"
	end,
})

vim.opt.updatetime = 200
vim.opt.timeoutlen = 300

-- Wrapping global desactivado (ideal para código)
-- Se activa localmente en orgmode/markdown según sea necesario
vim.opt.wrap = true

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

-- ===== Floating windows: sin borde por defecto =====
-- Neovim 0.11: borde por defecto de TODOS los flotantes que no especifiquen uno
-- (LSP hover, diagnostics, etc.). Los plugins que fijan su propio borde se
-- ajustan en su config; colorscheme.lua además hace invisibles los *Border.
vim.opt.winborder = "none"

-- ===== Transparency =====
-- El editor queda transparente; los menús/flotantes llevan un fondo de panel
-- (más opaco) que se define de forma autoritativa en colorscheme.lua.
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#181825" })

-- ===== Default filetype for new buffers =====
-- New unnamed buffers open as markdown by default
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		if vim.bo.buftype == "" and vim.fn.expand("%") == "" and vim.bo.filetype == "" then
			vim.bo.filetype = "markdown"
		end
	end,
})
